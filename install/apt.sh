#!/bin/bash
set -euo pipefail

[[ "$(uname -s)" == "Linux" ]] || { echo "Linux is required." >&2; exit 1; }
command -v apt-get >/dev/null || { echo "Automatic package installation supports Debian/Ubuntu. See README for other distributions." >&2; exit 1; }

SUDO=()
if [[ "$(id -u)" != 0 ]]; then
    command -v sudo >/dev/null || { echo "sudo is required to install system packages." >&2; exit 1; }
    SUDO=(sudo)
fi

${SUDO[@]+"${SUDO[@]}"} apt-get update
${SUDO[@]+"${SUDO[@]}"} apt-get install -y --no-install-recommends \
    stow git jq tmux zsh fzf ripgrep direnv openssh-client ncurses-term \
    python3 python3-pip python3-venv python3-pylsp pipx \
    build-essential clangd clang-format cmake pkg-config \
    curl ca-certificates tar xz-utils unzip

# Do not change the account's login shell automatically on a remote server.
