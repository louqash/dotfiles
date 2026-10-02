vim.opt.guicursor = ""

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.splitright = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(vim.opt.undodir:get()[1], "p")
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.opt.foldmethod = "indent"

vim.g.netrw_banner = 0 -- Hide banner
vim.g.netrw_browse_split = 0 -- Open files in the same netrw window (replace it)
vim.g.netrw_altv = 1 -- Open with right splitting
vim.g.netrw_preview = 1 -- Use Vertical splits
vim.g.netrw_liststyle = 3 -- Tree-style view
vim.g.netrw_winsize = 25 -- Side explorer / drawer takes 25% width

-- Copy through the SSH terminal instead of depending on a desktop clipboard.
-- Clipboard reads are intentionally local to Neovim's unnamed register.
local function paste_yank()
  return vim.fn.getreg('"', 1, true), vim.fn.getregtype('"')
end
vim.g.clipboard = {
  name = "OSC 52 (copy only)",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = { ["+"] = paste_yank, ["*"] = paste_yank },
}

-- Ordinary yanks also reach the client clipboard, without copying deletions or
-- changing how unnamed-register pastes work on the server.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("RemoteClipboard", { clear = true }),
  callback = function()
    local event = vim.v.event
    if event.operator == "y" and event.regname ~= "+" and event.regname ~= "*" then
      require("vim.ui.clipboard.osc52").copy("+")(event.regcontents)
    end
  end,
})
