#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OS="$(uname -s)"

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

link() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"

    if [[ -L "$dest" ]]; then
        rm "$dest"
    elif [[ -e "$dest" ]]; then
        info "Backing up $dest → ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    ln -s "$src" "$dest"
    echo "  $dest → $src"
}

info "Creating symlinks..."

# Remove only obsolete links owned by this checkout.
for obsolete in "$HOME/.config/wezterm" "$HOME/scripts/raycast_alacritty.sh"; do
    if [[ -L "$obsolete" ]]; then
        case "$(readlink "$obsolete")" in
            "$DOTFILES_DIR/config/wezterm"|"$DOTFILES_DIR/scripts/raycast_alacritty.sh")
                unlink "$obsolete"
                ;;
        esac
    fi
done

link "$DOTFILES_DIR/config/zshrc"          "$HOME/.zshrc"
link "$DOTFILES_DIR/config/nvim"           "$HOME/.config/nvim"
if [[ "$OS" == "Darwin" ]]; then
    link "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"
fi
link "$DOTFILES_DIR/config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

mkdir -p "$HOME/scripts"
for script in "$DOTFILES_DIR/scripts/"*; do
    link "$script" "$HOME/scripts/$(basename "$script")"
done

if [[ "$OS" == "Darwin" ]]; then
    link "$DOTFILES_DIR/config/karabiner" "$HOME/.config/karabiner"
fi
