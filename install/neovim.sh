#!/bin/bash
set -euo pipefail

[[ "$(uname -s)" == "Linux" ]] || { echo "Linux is required." >&2; exit 1; }
PREFIX="${1:-$HOME/.local}"
VERSION=v0.11.5
case "$(uname -m)" in
    x86_64) ARCH=x86_64; SHA256=b2f91117be5b5ea39edd7297156dc2a4a8df4add6c95a90809a8df19e7ab6f52 ;;
    aarch64|arm64) ARCH=arm64; SHA256=ea4f9a31b11cc1477ff014aebb7b207684e7280f94ffa97abdab6cacd9b98519 ;;
    *) echo "Supported architectures: x86_64 and aarch64." >&2; exit 1 ;;
esac
INSTALL_DIR="$PREFIX/opt/nvim-$VERSION"

if [[ ! -x "$INSTALL_DIR/bin/nvim" ]]; then
    TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TEMP_DIR"' EXIT
    ASSET="nvim-linux-$ARCH.tar.gz"
    curl --fail --location --retry 3 \
        "https://github.com/neovim/neovim/releases/download/$VERSION/$ASSET" \
        --output "$TEMP_DIR/$ASSET"
    printf '%s  %s\n' "$SHA256" "$TEMP_DIR/$ASSET" | sha256sum --check --status
    tar -xzf "$TEMP_DIR/$ASSET" -C "$TEMP_DIR"
    # Fail before changing links if the server cannot run the release binary.
    "$TEMP_DIR/nvim-linux-$ARCH/bin/nvim" --version >/dev/null
    mkdir -p "$PREFIX/opt"
    if [[ -e "$INSTALL_DIR" ]]; then
        echo "Incomplete installation exists at $INSTALL_DIR; move it aside and retry." >&2
        exit 1
    fi
    mv "$TEMP_DIR/nvim-linux-$ARCH" "$INSTALL_DIR"
fi

"$INSTALL_DIR/bin/nvim" --version >/dev/null
mkdir -p "$PREFIX/bin"
if [[ -e "$PREFIX/bin/nvim" || -L "$PREFIX/bin/nvim" ]]; then
    if [[ ! -L "$PREFIX/bin/nvim" || "$(readlink "$PREFIX/bin/nvim")" != "$INSTALL_DIR/bin/nvim" ]]; then
        BACKUP="$(mktemp "$PREFIX/bin/nvim.backup.XXXXXXXX")"
        mv "$PREFIX/bin/nvim" "$BACKUP"
        echo "Previous nvim entry preserved at $BACKUP"
    fi
fi
ln -sfn "$INSTALL_DIR/bin/nvim" "$PREFIX/bin/nvim"
echo "Neovim $VERSION ready at $PREFIX/bin/nvim"
