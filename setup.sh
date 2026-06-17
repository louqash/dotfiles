#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
success() { printf "\033[1;32m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }

OS="$(uname -s)"

info "Setting up dotfiles ($OS)..."

if [[ "$OS" == "Darwin" ]]; then
    "$DOTFILES_DIR/install/brew.sh"
elif [[ "$OS" == "Linux" ]]; then
    "$DOTFILES_DIR/install/apt.sh"
fi

"$DOTFILES_DIR/install/rust.sh"
"$DOTFILES_DIR/install/symlink.sh"
"$DOTFILES_DIR/install/tpm.sh"

if [[ "$OS" == "Darwin" ]]; then
    "$DOTFILES_DIR/install/macos-defaults.sh"
fi

success "Done! Open a new terminal to pick up changes."
if [[ "$OS" == "Darwin" ]]; then
    echo "  - In tmux, press \` + I to install TPM plugins (catppuccin theme)"
fi
