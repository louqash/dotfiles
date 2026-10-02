vim.g.mapleader = " "
-- Open netrw in an even 50/50 vertical split (not netrw's small winsize pane).
vim.keymap.set("n", "<leader>pv", function()
  vim.cmd.vsplit()
  vim.cmd.Explore()
end)
-- Toggle a left-sidebar file tree (netrw). Press again to close it.
vim.keymap.set("n", "<leader>pt", ":Lexplore<CR>", { desc = "Toggle netrw tree" })

-- move lines up or down and autoindent
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "<leader>c", "\"+y")
vim.keymap.set("v", "<leader>v", "\"+p")

-- keep cursor in the middle when going page up or down
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- paste over text without changing your yank buffer
vim.keymap.set("x", "<leader>p", "\"_dP")

vim.keymap.set("n", "<leader>y", "\"+y")

vim.keymap.set("n", "<leader>ww", ":w<CR>")
