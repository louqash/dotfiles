#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="$HOME"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            [[ $# -ge 2 ]] || { echo "--target requires a directory" >&2; exit 1; }
            TARGET_DIR="$2"
            shift 2
            ;;
        --dry-run) DRY_RUN=true; shift ;;
        *) echo "Usage: $0 [--target DIRECTORY] [--dry-run]" >&2; exit 1 ;;
    esac
done

command -v stow >/dev/null || { echo "Install GNU Stow first (sudo apt-get install stow)." >&2; exit 1; }
[[ -d "$TARGET_DIR" ]] || { echo "Target directory does not exist: $TARGET_DIR" >&2; exit 1; }
TARGET_DIR="$(cd "$TARGET_DIR" && pwd -P)"

PACKAGES=(zsh nvim tmux)

REMOVE_LINKS=()
BACKUP_PATHS=()
shopt -s dotglob nullglob

queue_backup() {
    local relative="$1" existing
    for existing in ${BACKUP_PATHS[@]+"${BACKUP_PATHS[@]}"}; do
        [[ "$existing" == "$relative" ]] && return
    done
    BACKUP_PATHS+=("$relative")
}

# Recognize only links created by the former installer, even if now dangling.
is_legacy_link() {
    local dest="$1" relative="$2" old_source=""
    [[ -L "$dest" ]] || return 1
    case "$relative" in
        .zshrc) old_source="$DOTFILES_DIR/config/zshrc" ;;
        .config/nvim) old_source="$DOTFILES_DIR/config/nvim" ;;
        .config/tmux/tmux.conf) old_source="$DOTFILES_DIR/config/tmux/tmux.conf" ;;
        *) return 1 ;;
    esac
    [[ "$(readlink "$dest")" == "$old_source" ]]
}

plan_path() {
    local src="$1" relative="$2" dest="$TARGET_DIR/$2" child
    if is_legacy_link "$dest" "$relative"; then
        REMOVE_LINKS+=("$relative")
        return
    fi
    if [[ -d "$src" && ! -L "$src" ]]; then
        if [[ -L "$dest" ]]; then
            if [[ "$dest" -ef "$src" ]]; then
                # Unfold an existing Stow-owned directory into per-file links.
                REMOVE_LINKS+=("$relative")
            elif [[ "$relative" == ".config" ]]; then
                echo "Cannot migrate a shared .config symlink automatically: $dest" >&2
                exit 1
            else
                queue_backup "$relative"
            fi
            return
        elif [[ -e "$dest" && ! -d "$dest" ]]; then
            queue_backup "$relative"
            return
        elif [[ ! -d "$dest" ]]; then
            return
        fi
        for child in "$src"/*; do
            plan_path "$child" "$relative/$(basename "$child")"
        done
    elif [[ -L "$dest" && "$dest" -ef "$src" ]]; then
        return
    elif [[ -e "$dest" || -L "$dest" ]]; then
        queue_backup "$relative"
    fi
}

for package in "${PACKAGES[@]}"; do
    for source in "$DOTFILES_DIR/stow/$package"/*; do
        plan_path "$source" "$(basename "$source")"
    done
done

for relative in ${REMOVE_LINKS[@]+"${REMOVE_LINKS[@]}"}; do
    echo "Migrate owned link: $TARGET_DIR/$relative"
done
for relative in ${BACKUP_PATHS[@]+"${BACKUP_PATHS[@]}"}; do
    echo "Back up conflict: $TARGET_DIR/$relative"
done

STOW_ARGS=(--dir="$DOTFILES_DIR/stow" --target="$TARGET_DIR" --no-folding --verbose)
if "$DRY_RUN"; then
    if [[ ${#REMOVE_LINKS[@]} -eq 0 && ${#BACKUP_PATHS[@]} -eq 0 ]]; then
        stow "${STOW_ARGS[@]}" --simulate "${PACKAGES[@]}"
    else
        echo "Dry run: after the above migration, Stow will link: ${PACKAGES[*]}"
    fi
    exit 0
fi

if [[ ${#BACKUP_PATHS[@]} -gt 0 ]]; then
    BACKUP_DIR="$(mktemp -d "$TARGET_DIR/.dotfiles-backup.XXXXXXXX")"
    for relative in "${BACKUP_PATHS[@]}"; do
        mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
        mv "$TARGET_DIR/$relative" "$BACKUP_DIR/$relative"
    done
    echo "Conflicting files preserved in: $BACKUP_DIR"
fi
for relative in ${REMOVE_LINKS[@]+"${REMOVE_LINKS[@]}"}; do
    # These are verified owned symlinks, never real files or directories.
    unlink "$TARGET_DIR/$relative"
done

# Refuse any remaining conflicts before asking Stow to create links.
stow "${STOW_ARGS[@]}" --simulate "${PACKAGES[@]}"
stow "${STOW_ARGS[@]}" "${PACKAGES[@]}"
