# dotfiles

Personal dotfiles for macOS and Linux.

## Quick start

```bash
git clone <repo-url> ~/workplace/dotfiles
cd ~/workplace/dotfiles
./setup.sh
```

This will:
- Install packages (Homebrew on macOS, apt on Linux)
- Install Rust via rustup
- Symlink all config files into place
- Install Tmux Plugin Manager + plugins
- Apply macOS system defaults (macOS only)

After setup, open a new terminal. In tmux, press `` ` + I `` to install plugins.

## What's included

| Config | Location | Description |
|--------|----------|-------------|
| zshrc | `~/.zshrc` | Zsh with pure prompt, fzf, pyenv, nvm, direnv |
| nvim | `~/.config/nvim` | Neovim with LSP, telescope, treesitter, catppuccin |
| alacritty | `~/.config/alacritty` | GPU terminal, JetBrains Mono, catppuccin |
| tmux | `~/.config/tmux` | Catppuccin theme via TPM, backtick prefix |
| karabiner | `~/.config/karabiner` | Caps Lock → Escape (macOS) |

## Adding/removing packages

Edit `Brewfile` and run `brew bundle --file=Brewfile`.

## Re-running

`./setup.sh` is idempotent — safe to run again after changes.
