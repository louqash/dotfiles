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
| zshrc | `~/.zshrc` | Zsh with pure prompt, fzf, pyenv, direnv |
| nvim | `~/.config/nvim` | Neovim with LSP, telescope, treesitter, catppuccin |
| ghostty | `~/.config/ghostty` | Terminal, JetBrains Mono, Solarized Light |
| tmux | `~/.config/tmux` | Catppuccin theme via TPM, backtick prefix |
| karabiner | `~/.config/karabiner` | Caps Lock → Escape (macOS) |

## Desktop shortcuts (macOS)

Ctrl+1 through Ctrl+9 switch to the corresponding desktop; Ctrl+0 switches to
Desktop 10. Setup enables these shortcuts, or you can apply them separately:

```bash
./install/macos-desktop-shortcuts.sh --dry-run
./install/macos-desktop-shortcuts.sh
```

Create the desktops in Mission Control first. The script saves existing keyboard
shortcuts under `~/.local/state/dotfiles/desktop-shortcuts.*` and preserves unrelated
shortcuts. If macOS does not activate them immediately, log out and back in.

## Adding/removing packages

Edit `Brewfile` and run `brew bundle --file=Brewfile`.

## Re-running

`./setup.sh` is idempotent — safe to run again after changes.
