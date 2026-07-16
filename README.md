# dotfiles

Personal dotfiles for macOS and Linux.

## Quick start

```bash
git clone <repo-url> ~/workplace/dotfiles
cd ~/workplace/dotfiles
./setup.sh
```

This will:
- Install packages (Homebrew on macOS, `apt` on Linux)
- Install Rust via rustup
- Symlink all config files into place
- Install Tmux Plugin Manager + plugins
- Apply macOS system defaults (macOS only)

After setup, open a new terminal. In tmux, press `` ` + I `` to install plugins.

## Platforms

`setup.sh` auto-detects the OS and installs packages accordingly:

| OS | Package manager |
|----|-----------------|
| macOS | Homebrew (`Brewfile`) |
| Linux | `apt` (`install/apt.sh`) — needs sudo |

**Graceful degradation:** the `zshrc` is cross-platform and guards every
integration (`brew`, `fzf`, `pyenv`, `direnv`, `pure`, `nvim`, …) behind a
`command -v` check, so a missing tool just skips its config instead of
erroring. The prompt falls back to a plain one when `pure` isn't installed, and
`vim`/`vi` fall back gracefully when `nvim` is absent.

## What's included

| Config | Location | Description |
|--------|----------|-------------|
| zshrc | `~/.zshrc` | Zsh with pure prompt, fzf, pyenv, nvm, direnv |
| nvim | `~/.config/nvim` | Neovim with LSP, telescope, treesitter, catppuccin |
| alacritty | `~/.config/alacritty` | GPU terminal, JetBrains Mono, catppuccin |
| tmux | `~/.config/tmux` | Catppuccin theme via TPM, backtick prefix |
| karabiner | `~/.config/karabiner` | Caps Lock → Escape (macOS) |

## Adding/removing packages

- **macOS:** edit `Brewfile` and run `brew bundle --file=Brewfile`.
- **Linux:** edit the package lists in `install/apt.sh`.

## Re-running

`./setup.sh` is idempotent — safe to run again after changes.
