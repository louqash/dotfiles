#!/bin/bash
set -uo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }

info "Updating apt..."
sudo apt update || warn "apt update failed — continuing anyway."

# Core packages available on all supported Debian/Ubuntu releases.
CORE_PACKAGES=(
    git
    jq
    pipx
    tmux
    neovim
    direnv
    python3 python3-pip python3-venv
    xz-utils
    libreadline-dev
    fzf
    ripgrep
    watch
    cmake
    pkg-config
    zsh
    curl
)

# Newer packages that may be missing on older releases — installed best-effort.
OPTIONAL_PACKAGES=(
    just
    gh
)

info "Installing core packages..."
sudo apt install -y "${CORE_PACKAGES[@]}" || warn "Some core packages failed to install."

info "Installing optional packages (best effort)..."
for pkg in "${OPTIONAL_PACKAGES[@]}"; do
    if sudo apt install -y "$pkg" 2>/dev/null; then
        echo "  installed: $pkg"
    else
        warn "skipped (unavailable on this release): $pkg"
    fi
done

info "Setting zsh as default shell..."
if [[ "$SHELL" != */zsh ]] && command -v zsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" || warn "chsh failed — run 'chsh -s $(command -v zsh)' manually."
fi
