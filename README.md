# Remote Linux dotfiles

Terminal-only configuration for remote development over SSH: zsh, tmux, Neovim,
and GNU Stow. Automatic setup supports Debian 12+ and Ubuntu 22.04+ on x86_64
or aarch64, with sudo access and outbound HTTPS access.

## Setup

```bash
git clone --branch remote <repo-url> ~/dotfiles
cd ~/dotfiles
./setup.sh
exec zsh
tmux new -As work
```

Setup installs command-line dependencies through apt, installs a checksum-verified
Neovim 0.11.5 release under `~/.local/opt`, and creates per-file Stow links. It
preserves conflicting configuration under `~/.dotfiles-backup.*` and leaves the
account's login shell unchanged. If desired, change it manually with
`chsh -s "$(command -v zsh)"` after confirming zsh starts correctly.

Neovim is installed separately because distribution packages can be too old for
the language-server configuration. `~/.local/bin` takes priority in zsh. The
configuration uses Neovim 0.11.x and nvim-treesitter's frozen `master` branch;
upgrading to Neovim 0.12 also requires migrating that plugin. Existing entries at
`~/.local/bin/nvim` are backed up before replacement. First launch downloads
Neovim plugins and compiles syntax parsers; it needs GitHub access and a C compiler.

Other Linux distributions can use the configuration after installing equivalent
command-line dependencies manually. Run `install/neovim.sh` and `install/stow.sh`
afterward. The supplied Neovim binaries require a compatible glibc-based system.

## Packages

| Stow package | Destination | Contents |
|--------------|-------------|----------|
| zsh | `~/.zshrc` | Host-aware prompt, history, fzf, optional pyenv and direnv |
| tmux | `~/.config/tmux/tmux.conf` | Persistent sessions, pane shortcuts, copy mode |
| nvim | `~/.config/nvim` | LSP, completion, Telescope, Treesitter, Git, undo history |

Edit files inside `stow/` to change settings. Per-file links keep directories real,
so new runtime files remain outside the repository.

```bash
./install/stow.sh --dry-run
./install/stow.sh
```

The installer migrates links from the former layout, backs up conflicts, and
preserves unrelated files. A shared `.config` symlink requires manual migration;
the installer stops before changing it.

Link or unlink an individual package:

```bash
stow --dir=stow --target="$HOME" --no-folding tmux
stow --dir=stow --target="$HOME" --no-folding --delete tmux
```

Unlink packages before deleting or renaming their directories. After removing a
file from a package, use `--restow` to remove its stale link.

## Remote workflow

The tmux prefix is backtick. Use prefix + `h/j/k/l` to move between panes,
prefix + `d` to detach, and `tmux new -As work` to reconnect. Copy mode uses vi
keys: prefix + `[` enters copy mode, `v` starts selection, and `y` or Enter copies
to your Mac clipboard. Dragging a selection with the mouse copies on release.
OSC 52 also works through nested tmux sessions when both use this configuration.
There is no tmux plugin manager to bootstrap.
New windows and panes use zsh even when the account's login shell is Bash.
After reloading the configuration, run `exec zsh` in existing Bash panes.

Neovim's leader is Space. `<leader>pf` searches files, `<leader>fg` searches text,
`<leader>gs` opens Git status. Ordinary yanks (`yy`, `yw`, or visual `y`) and
`<leader>y` copy through OSC 52 to your Mac clipboard. Deletions leave it unchanged.
The SSH client terminal must support OSC 52 and allow clipboard writes; Ghostty
allows these by default (`clipboard-write = allow`). Paste on your Mac with Cmd+V.
Reload an existing remote tmux server with
`tmux source-file ~/.config/tmux/tmux.conf`, then detach and reconnect the client
so its terminal capabilities are refreshed. Clipboard reads
use Neovim's last server-side yank; use your terminal's paste shortcut to paste
from the local clipboard. No display server or clipboard utility is required.
See [the keymap reference](stow/nvim/.config/nvim/KEYMAPS.md).

Forwarded `SSH_AUTH_SOCK`, negotiated `TERM`, and the server locale are preserved.
Optional shell additions go in `~/.zshrc.local`. Neovim uses system clangd;
Mason installs Pyrefly for Python navigation/type checking and Ruff for
linting/formatting on first launch. Python environment detection supports
project virtual environments (including `build/venv`), activated virtualenvs
and Conda, and Poetry when available; setup does not install Poetry.

## Checks

```bash
python3 -m unittest discover -s tests -v
bash -n setup.sh install/*.sh
zsh -n stow/zsh/.zshrc
```
