#!/bin/bash
set -euo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

info "Skipping Rust setup (install manually with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.sh | sh)"
