#!/bin/bash
set -uo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }

# tmux plugins need git + tmux. Skip gracefully if either is missing.
if ! command -v git >/dev/null 2>&1; then
    warn "git not found — skipping tmux plugin manager setup."
    exit 0
fi
if ! command -v tmux >/dev/null 2>&1; then
    warn "tmux not found — skipping tmux plugin manager setup."
    exit 0
fi

TPM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"

if [[ -d "$TPM_DIR" ]]; then
    info "TPM already installed."
else
    info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" || {
        warn "Failed to clone TPM — skipping."
        exit 0
    }
fi

info "Installing tmux plugins..."
"$TPM_DIR/bin/install_plugins" || true
