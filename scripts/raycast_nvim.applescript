#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Neovim
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗒️

# Documentation:
# @raycast.description Starts new neovim window in Ghostty
# @raycast.author Louqash

on run

  tell application "Finder"
    if exists (front window) then
      set dirPath to POSIX path of (target of front window as alias)
    else
      set dirPath to POSIX path of (home as alias)
    end if
  end tell

  do shell script "open -na Ghostty --args --working-directory=" & quoted form of dirPath & " -e /opt/homebrew/bin/nvim"

end run
