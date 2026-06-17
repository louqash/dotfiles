local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "Solarized (light) (terminal.sexy)"

-- Font
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14.0

-- Window
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = { left = 10, right = 10, top = 10, bottom = 10 }
config.window_decorations = "TITLE | RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.native_macos_fullscreen_mode = true

-- Cursor
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 750

-- Tab bar
config.enable_tab_bar = false

-- Initial window size
config.initial_cols = 100
config.initial_rows = 30

-- Shell
config.default_prog = { "/bin/zsh" }

-- No update notifications or bell
config.check_for_updates = false
config.audible_bell = "Disabled"

-- Keys
config.keys = {
    { key = "n", mods = "CMD", action = wezterm.action.SpawnWindow },
    { key = "w", mods = "CMD", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
    { key = "d", mods = "CMD", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d", mods = "CMD|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    -- Pane navigation (vim-style)
    { key = "h", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "j", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
    { key = "k", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "l", mods = "CMD|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
}

return config
