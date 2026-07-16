#!/bin/bash
# Linux setup without sudo: install everything into the user's home directory
# using a static micromamba binary + conda-forge. Anything that can't be
# installed is skipped with a warning rather than aborting the whole run.
set -uo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
success() { printf "\033[1;32m==>\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m==>\033[0m %s\n" "$1"; }

BIN_DIR="$HOME/.local/bin"
export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-$HOME/.local/share/mamba}"
MICROMAMBA="$BIN_DIR/micromamba"
ENV_NAME="dotfiles"

# conda-forge packages. Names differ from Homebrew/apt:
#   github-cli -> gh, tree-sitter-cli -> tree-sitter, procps-ng -> watch
# NOTE: the conda-forge package literally named `neovim` is the pynvim Python
# client, NOT the editor. Neovim itself is installed from its official static
# release below (install_neovim), since conda-forge has no editor package.
PACKAGES=(
    git
    jq
    tmux
    direnv
    python
    fzf
    ripgrep
    zsh
    nodejs
    just
    tree-sitter-cli   # required by nvim-treesitter `main` branch
    c-compiler        # compiles treesitter parsers at runtime (:TSInstall)
    make
    cmake
    pkg-config
    github-cli
    poetry
    procps-ng   # provides `watch`
)

mkdir -p "$BIN_DIR" "$MAMBA_ROOT_PREFIX"

if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    warn "Neither curl nor wget is available — cannot bootstrap micromamba. Skipping package install."
    exit 0
fi

fetch() {
    # fetch URL -> stdout
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1"
    else
        wget -qO- "$1"
    fi
}

# ----- Detect platform for micromamba download -----
case "$(uname -m)" in
    x86_64|amd64)   MM_PLATFORM="linux-64" ;;
    aarch64|arm64)  MM_PLATFORM="linux-aarch64" ;;
    ppc64le)        MM_PLATFORM="linux-ppc64le" ;;
    *) warn "Unsupported architecture $(uname -m) for micromamba. Skipping package install."; exit 0 ;;
esac

# ----- Bootstrap micromamba -----
if [[ -x "$MICROMAMBA" ]]; then
    info "micromamba already installed."
else
    info "Bootstrapping micromamba ($MM_PLATFORM)..."
    # The release tarball contains bin/micromamba
    if fetch "https://micro.mamba.pm/api/micromamba/${MM_PLATFORM}/latest" \
        | tar -xj -C "$HOME/.local" bin/micromamba 2>/dev/null; then
        chmod +x "$MICROMAMBA"
        success "micromamba installed to $MICROMAMBA"
    else
        warn "Failed to download micromamba. Skipping package install."
        exit 0
    fi
fi

# ----- Create / update the env -----
info "Installing packages into micromamba env '$ENV_NAME' (this may take a while)..."
if ! "$MICROMAMBA" create -y -n "$ENV_NAME" -c conda-forge "${PACKAGES[@]}" 2>/dev/null; then
    warn "Bulk install failed — retrying packages one by one (some may be unavailable)."
    # Ensure the env exists first.
    "$MICROMAMBA" create -y -n "$ENV_NAME" -c conda-forge python 2>/dev/null || true
    for pkg in "${PACKAGES[@]}"; do
        if "$MICROMAMBA" install -y -n "$ENV_NAME" -c conda-forge "$pkg" 2>/dev/null; then
            echo "  installed: $pkg"
        else
            warn "skipped (unavailable): $pkg"
        fi
    done
fi

# ----- Install Neovim (official static release; conda-forge has no editor) -----
install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        info "nvim already on PATH — skipping Neovim download."
        return 0
    fi
    case "$(uname -m)" in
        x86_64|amd64)  nv_assets=("nvim-linux-x86_64.tar.gz" "nvim-linux64.tar.gz") ;;
        aarch64|arm64) nv_assets=("nvim-linux-arm64.tar.gz") ;;
        *) warn "No prebuilt Neovim for $(uname -m) — skipping (edit config still symlinked)."; return 0 ;;
    esac

    local dest="$HOME/.local/opt/nvim"
    mkdir -p "$HOME/.local/opt"
    for asset in "${nv_assets[@]}"; do
        info "Downloading Neovim ($asset)..."
        rm -rf "$dest"; mkdir -p "$dest"
        # Tarball top dir (e.g. nvim-linux-x86_64/) is stripped so bin/, lib/,
        # share/ land directly in $dest; nvim resolves its runtime relative to
        # the real binary path, so the ~/.local/bin symlink stays correct.
        if fetch "https://github.com/neovim/neovim/releases/latest/download/$asset" \
            | tar -xz --strip-components=1 -C "$dest" 2>/dev/null && [[ -x "$dest/bin/nvim" ]]; then
            ln -sf "$dest/bin/nvim" "$BIN_DIR/nvim"
            success "Neovim installed ($("$dest/bin/nvim" --version | head -1))."
            return 0
        fi
    done
    rm -rf "$dest"
    warn "Could not download Neovim — skipping (its config is still symlinked for when nvim is available)."
}
install_neovim

# ----- Install pure prompt (not on conda-forge) -----
PURE_DIR="$HOME/.zsh/pure"
if [[ ! -d "$PURE_DIR" ]]; then
    if command -v git >/dev/null 2>&1 || [[ -x "$MAMBA_ROOT_PREFIX/envs/$ENV_NAME/bin/git" ]]; then
        info "Installing pure prompt..."
        GIT_BIN="$(command -v git || echo "$MAMBA_ROOT_PREFIX/envs/$ENV_NAME/bin/git")"
        "$GIT_BIN" clone --depth 1 https://github.com/sindresorhus/pure.git "$PURE_DIR" 2>/dev/null \
            || warn "Could not clone pure prompt (zshrc falls back to a plain prompt)."
    fi
fi

# ----- Make zsh the interactive shell without chsh (which needs /etc/shells) -----
ZSH_BIN="$MAMBA_ROOT_PREFIX/envs/$ENV_NAME/bin/zsh"
if [[ -x "$ZSH_BIN" ]]; then
    LAUNCHER="# >>> dotfiles zsh launcher >>>
# Launch the micromamba-provided zsh for interactive shells (no sudo/chsh needed).
if [ -x \"$ZSH_BIN\" ] && [ -z \"\${ZSH_VERSION:-}\" ] && [ -t 1 ] && [ -z \"\${DOTFILES_NO_ZSH:-}\" ]; then
    export SHELL=\"$ZSH_BIN\"
    exec \"$ZSH_BIN\" -l
fi
# <<< dotfiles zsh launcher <<<"
    for rc in "$HOME/.bashrc" "$HOME/.profile"; do
        if [[ ! -f "$rc" ]] || ! grep -q "dotfiles zsh launcher" "$rc" 2>/dev/null; then
            printf '\n%s\n' "$LAUNCHER" >> "$rc"
            info "Added zsh launcher to $rc"
        fi
    done
fi

success "No-sudo Linux setup complete."
