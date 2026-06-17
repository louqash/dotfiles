#!/bin/bash
set -euo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TPM_DIR" ]]; then
    info "TPM already installed."
else
    info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

info "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" || true
