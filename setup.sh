#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
success() { printf "\033[1;32m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }

usage() {
    cat <<'EOF'
Usage: ./setup.sh [--variant VARIANT]

Variants:
  macos          macOS (Homebrew)
  linux-sudo     Linux with sudo access (apt)
  linux-nosudo   Linux without sudo (micromamba/conda-forge, best effort)

If --variant is omitted it is auto-detected. You can also set DOTFILES_VARIANT.
EOF
}

# Returns 0 if we can use sudo (root, passwordless, or an interactive prompt succeeds).
has_sudo() {
    [[ "$(id -u)" -eq 0 ]] && return 0
    command -v sudo >/dev/null 2>&1 || return 1
    sudo -n true 2>/dev/null && return 0
    # sudo exists but may need a password; only try interactively.
    [[ -t 0 ]] && sudo -v 2>/dev/null && return 0
    return 1
}

# ----- Parse args -----
VARIANT="${DOTFILES_VARIANT:-}"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --variant) VARIANT="${2:-}"; shift 2 ;;
        --variant=*) VARIANT="${1#*=}"; shift ;;
        -h|--help) usage; exit 0 ;;
        *) warn "Unknown argument: $1"; usage; exit 1 ;;
    esac
done

OS="$(uname -s)"

# ----- Detect variant -----
if [[ -z "$VARIANT" ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        VARIANT="macos"
    elif [[ "$OS" == "Linux" ]]; then
        if has_sudo; then
            VARIANT="linux-sudo"
        else
            VARIANT="linux-nosudo"
        fi
    else
        warn "Unsupported OS: $OS — proceeding with symlinks only."
        VARIANT="none"
    fi
fi

info "Setting up dotfiles (OS: $OS, variant: $VARIANT)..."

# ----- Install packages -----
case "$VARIANT" in
    macos)        "$DOTFILES_DIR/install/brew.sh" ;;
    linux-sudo)   "$DOTFILES_DIR/install/apt.sh" ;;
    linux-nosudo) "$DOTFILES_DIR/install/linux-nosudo.sh" ;;
    none)         warn "Skipping package installation." ;;
    *)            warn "Unknown variant '$VARIANT'"; usage; exit 1 ;;
esac

# ----- Common steps -----
"$DOTFILES_DIR/install/rust.sh"
"$DOTFILES_DIR/install/symlink.sh"
"$DOTFILES_DIR/install/tpm.sh"

# ----- macOS-only steps -----
if [[ "$VARIANT" == "macos" ]]; then
    "$DOTFILES_DIR/install/macos-defaults.sh"
fi

success "Done! Open a new terminal to pick up changes."
if [[ "$VARIANT" == "macos" ]]; then
    echo "  - In tmux, press \` + I to install TPM plugins (catppuccin theme)"
fi
if [[ "$VARIANT" == "linux-nosudo" ]]; then
    echo "  - Tools were installed into a micromamba env under ~/.local/share/mamba."
    echo "  - If zsh isn't your login shell, a launcher was added to ~/.bashrc / ~/.profile."
fi
