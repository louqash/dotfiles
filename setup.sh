#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
[[ "$(uname -s)" == "Linux" ]] || { echo "This branch is for Linux servers." >&2; exit 1; }

"$DOTFILES_DIR/install/apt.sh"
"$DOTFILES_DIR/install/neovim.sh"
"$DOTFILES_DIR/install/stow.sh"

echo "Done. Reconnect over SSH or run exec zsh. Start a session with tmux new -As work."
