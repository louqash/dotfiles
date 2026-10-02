#!/bin/bash
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || { echo "This script requires macOS." >&2; exit 1; }
[[ $# -eq 0 || ( $# -eq 1 && "$1" == "--dry-run" ) ]] || {
    echo "Usage: $0 [--dry-run]" >&2
    exit 1
}

KEY_CODES=(18 19 20 21 23 22 26 28 25 29)
DOMAIN=com.apple.symbolichotkeys

if [[ "${1:-}" != "--dry-run" ]]; then
    BACKUP_ROOT="$HOME/.local/state/dotfiles"
    mkdir -p "$BACKUP_ROOT"
    BACKUP_DIR="$(mktemp -d "$BACKUP_ROOT/desktop-shortcuts.XXXXXXXX")"
    if defaults read "$DOMAIN" >/dev/null 2>&1; then
        defaults export "$DOMAIN" "$BACKUP_DIR/shortcuts.plist"
        echo "Previous keyboard shortcuts saved to $BACKUP_DIR/shortcuts.plist"
    fi
fi

for index in "${!KEY_CODES[@]}"; do
    desktop=$((index + 1))
    digit=$((desktop % 10))
    hotkey=$((118 + index))
    echo "Ctrl+$digit → Desktop $desktop"
    [[ "${1:-}" != "--dry-run" ]] || continue
    # These are Mission Control's numbered desktop actions. Control = 262144.
    defaults write "$DOMAIN" AppleSymbolicHotKeys -dict-add "$hotkey" \
        "<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>65535</integer><integer>${KEY_CODES[$index]}</integer><integer>262144</integer></array></dict></dict>"
done

if [[ "${1:-}" != "--dry-run" ]]; then
    ACTIVATE=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
    if [[ -x "$ACTIVATE" ]] && "$ACTIVATE" -u; then
        echo "Desktop shortcuts applied."
    else
        echo "Shortcuts saved. Log out and back in to activate them."
    fi
fi
echo "Create the desktops you need in Mission Control; this script only configures their shortcuts."
