# dotfiles

Personal dotfiles for macOS and Linux.

## Quick start

```bash
git clone <repo-url> ~/workplace/dotfiles
cd ~/workplace/dotfiles
./setup.sh
```

This will:
- Install packages (see variants below)
- Install Rust via rustup
- Symlink all config files into place
- Install Tmux Plugin Manager + plugins
- Apply macOS system defaults (macOS only)

After setup, open a new terminal. In tmux, press `` ` + I `` to install plugins.

## Variants

`setup.sh` auto-detects one of three variants and installs packages accordingly:

| Variant | When | Package manager |
|---------|------|-----------------|
| `macos` | macOS | Homebrew (`Brewfile`) |
| `linux-sudo` | Linux with sudo access | `apt` |
| `linux-nosudo` | Linux without sudo | [`micromamba`](https://mamba.readthedocs.io/) + conda-forge, installed under `~/.local` |

Override auto-detection with a flag or env var:

```bash
./setup.sh --variant linux-nosudo
# or
DOTFILES_VARIANT=linux-nosudo ./setup.sh
```

**No-sudo notes:** everything is installed into your home directory (a
micromamba env under `~/.local/share/mamba`), no root required. Tools that
aren't available are skipped rather than failing the run. Neovim is the one
exception to conda-forge — its editor isn't packaged there (the conda `neovim`
package is the `pynvim` client), so it's fetched from the official static
release into `~/.local/opt/nvim`. Since `chsh` needs
root to register a new shell, a launcher is appended to `~/.bashrc` /
`~/.profile` that `exec`s the micromamba `zsh` for interactive sessions (set
`DOTFILES_NO_ZSH=1` to disable it).

**Graceful degradation:** the `zshrc` guards every integration (`brew`, `fzf`,
`pyenv`, `direnv`, `pure`, `nvim`, …) behind a `command -v` check, so a missing
tool just skips its config instead of erroring. The prompt falls back to a
plain one when `pure` isn't installed, and `vim`/`vi` fall back gracefully when
`nvim` is absent.

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
- **Linux (sudo):** edit the package lists in `install/apt.sh`.
- **Linux (no sudo):** edit the `PACKAGES` list in `install/linux-nosudo.sh`.

## Re-running

`./setup.sh` is idempotent — safe to run again after changes.
