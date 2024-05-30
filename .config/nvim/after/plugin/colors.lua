function SetColorScheme(color)
	vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
	vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})
    -- mytheme.lua
    local colors = {
        ansi0 = "#766557", -- Ansi 0 Color
        ansi1 = "#dd5f57", -- Ansi 1 Color
        ansi2 = "#6fb368", -- Ansi 2 Color
        ansi3 = "#e9bd6f", -- Ansi 3 Color
        ansi4 = "#bbd8a8", -- Ansi 4 Color
        ansi5 = "#c3d143", -- Ansi 5 Color
        ansi6 = "#72a65b", -- Ansi 6 Color
        ansi7 = "#ffffff", -- Ansi 7 Color
        ansi8 = "#888888", -- Ansi 8 Color
        ansi9 = "#df7670", -- Ansi 9 Color
        ansi10 = "#eac686", -- Ansi 10 Color
        ansi11 = "#eac686", -- Ansi 11 Color
        ansi12 = "#8ab489", -- Ansi 12 Color
        ansi13 = "#d5d746", -- Ansi 13 Color
        ansi14 = "#8ab489", -- Ansi 14 Color
        ansi15 = "#ffffff", -- Ansi 15 Color
        background = "#343f39", -- Background Color
        foreground = "#ffffff", -- Foreground Color
        cursor = "#f1efee", -- Cursor Color
        cursor_text = "#342632", -- Cursor Text Color
        selection = "#547362", -- Selection Color
        selected_text = "#f1efee", -- Selected Text Color
    }

    vim.cmd("highlight clear")
    if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
    end

    vim.o.background = "dark"
    vim.o.termguicolors = true

    local highlights = {
        Normal = { fg = colors.foreground, bg = colors.background },
        Cursor = { fg = colors.cursor_text, bg = colors.cursor },
        Visual = { bg = colors.selection },
        VisualNOS = { bg = colors.selection },
        Search = { bg = colors.selection, fg = colors.selected_text },
        IncSearch = { bg = colors.selection, fg = colors.selected_text },
        MatchParen = { fg = colors.ansi13, bg = colors.background },
        Comment = { fg = colors.ansi8, italic = true },
        Constant = { fg = colors.ansi10 },
        String = { fg = colors.ansi10 },
        Character = { fg = colors.ansi10 },
        Number = { fg = colors.ansi9 },
        Boolean = { fg = colors.ansi9 },
        Float = { fg = colors.ansi9 },
        Identifier = { fg = colors.ansi4 },
        Function = { fg = colors.ansi4 },
        Statement = { fg = colors.ansi1 },
        Conditional = { fg = colors.ansi1 },
        Repeat = { fg = colors.ansi1 },
        Label = { fg = colors.ansi1 },
        Operator = { fg = colors.ansi5 },
        Keyword = { fg = colors.ansi1 },
        Exception = { fg = colors.ansi1 },
        PreProc = { fg = colors.ansi6 },
        Include = { fg = colors.ansi6 },
        Define = { fg = colors.ansi6 },
        Title = { fg = colors.ansi6, bold = true },
        Macro = { fg = colors.ansi6 },
        PreCondit = { fg = colors.ansi6 },
        Type = { fg = colors.ansi3 },
        StorageClass = { fg = colors.ansi3 },
        Structure = { fg = colors.ansi3 },
        Typedef = { fg = colors.ansi3 },
        Special = { fg = colors.ansi2 },
        SpecialChar = { fg = colors.ansi2 },
        Tag = { fg = colors.ansi2 },
        Delimiter = { fg = colors.ansi2 },
        SpecialComment = { fg = colors.ansi2 },
        Debug = { fg = colors.ansi2 },
        Underlined = { fg = colors.ansi4, underline = true },
        Bold = { bold = true },
        Italic = { italic = true },
        Ignore = { fg = colors.ansi8 },
        Error = { fg = colors.ansi9, bg = colors.background, bold = true },
        Todo = { fg = colors.ansi4, bg = colors.background, bold = true, italic = true },
    }

    for group, settings in pairs(highlights) do
        local gui = ""
        if settings.bold then
            gui = gui .. "bold,"
        end
        if settings.italic then
            gui = gui .. "italic,"
        end
        if settings.underline then
            gui = gui .. "underline,"
        end
        if gui == "" then
            gui = "NONE"
        end

        local fg = settings.fg and " guifg=" .. settings.fg or ""
        local bg = settings.bg and " guibg=" .. settings.bg or ""
        local sp = settings.sp and " guisp=" .. settings.sp or ""

        vim.cmd("highlight " .. group .. " gui=" .. gui .. fg .. bg .. sp)
    end
end

SetColorScheme()
