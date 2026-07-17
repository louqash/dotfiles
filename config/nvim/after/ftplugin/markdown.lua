-- Toggle the browser live-preview (markdown-preview.nvim) for the current file.
-- Buffer-local so <leader>mp only exists in markdown buffers.
vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>",
  { buffer = true, desc = "Markdown: toggle browser preview" })
