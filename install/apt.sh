#!/bin/bash
set -euo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

info "Updating apt..."
sudo apt update

info "Installing packages..."
sudo apt install -y \
    git \
    jq \
    pipx \
    tmux \
    neovim \
    direnv \
    python3 python3-pip python3-venv \
    xz-utils \
    just \
    libreadline-dev \
    fzf \
    ripgrep \
    watch \
    cmake \
    pkg-config \
    zsh

info "Setting zsh as default shell..."
if [[ "$SHELL" != */zsh ]]; then
    chsh -s "$(which zsh)"
fi
