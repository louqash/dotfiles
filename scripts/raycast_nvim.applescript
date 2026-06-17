#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Neovim
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🗒️

# Documentation:
# @raycast.description Starts new neovim window in WezTerm
# @raycast.author Louqash

on run

  tell application "Finder"
    if exists (front window) then
      set dirPath to POSIX path of (target of front window as alias)
    else
      set dirPath to POSIX path of (home as alias)
    end if
  end tell

  do shell script "/opt/homebrew/bin/wezterm cli spawn --cwd " & quoted form of dirPath & " -- /opt/homebrew/bin/nvim >/dev/null 2>&1 || /opt/homebrew/bin/wezterm start --cwd " & quoted form of dirPath & " -- /opt/homebrew/bin/nvim >/dev/null 2>&1 &"

end run
