#!/bin/bash
set -euo pipefail

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }

info "Applying macOS defaults..."

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock persistent-apps -array \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/WezTerm.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Obsidian.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Mail.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>' \
    '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/System/Applications/Calendar.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'

# Hot corners (1 = disabled)
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1

# Finder
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Accessibility
defaults write com.apple.universalaccess reduceMotion -bool true

# Login
defaults write com.apple.loginwindow GuestEnabled -bool false

# Global
defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Screenshots
mkdir -p "$HOME/Pictures/screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/screenshots"

# Screensaver
defaults write com.apple.screensaver askForPasswordDelay -int 10

# Restart affected apps
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

# Touch ID for sudo
if [[ -L /etc/pam.d/sudo_local && ! -e /etc/pam.d/sudo_local ]]; then
    info "Removing dangling sudo_local symlink (nix-darwin leftover)..."
    sudo rm /etc/pam.d/sudo_local
fi
if [[ ! -f /etc/pam.d/sudo_local ]] || ! grep -q pam_tid /etc/pam.d/sudo_local 2>/dev/null; then
    info "Enabling Touch ID for sudo (requires password)..."
    echo "auth       sufficient     pam_tid.so" | sudo tee /etc/pam.d/sudo_local > /dev/null
fi

info "macOS defaults applied."
