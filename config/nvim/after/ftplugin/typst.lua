-- Toggle the browser live-preview (typst-preview.nvim) for the current file.
-- Buffer-local so <leader>mp only exists in typst buffers; mirrors the same
-- mapping in markdown buffers (see markdown.lua).
vim.keymap.set("n", "<leader>mp", "<cmd>TypstPreviewToggle<cr>",
  { buffer = true, desc = "Typst: toggle browser preview" })
