-- Keep messages in English without changing the encoding inherited by tools.
vim.cmd("language messages C")
if vim.fn.has("macunix") == 1 then
    -- pbcopy/pbpaste interpret bytes using their locale, not Neovim's encoding.
    local copy = { "/usr/bin/env", "LC_ALL=en_US.UTF-8", "/usr/bin/pbcopy" }
    local paste = { "/usr/bin/env", "LC_ALL=en_US.UTF-8", "/usr/bin/pbpaste" }
    vim.g.clipboard = {
        name = "macOS UTF-8 clipboard",
        copy = { ["+"] = copy, ["*"] = copy },
        paste = { ["+"] = paste, ["*"] = paste },
        cache_enabled = 0,
    }
end
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

vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
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
vim.g.netrw_keepdir = 0 -- Keep the working directory in sync with netrw browsing
vim.g.netrw_browse_split = 0 -- Open files in the same netrw window (replace it)
vim.g.netrw_altv = 1 -- Open with right splitting
vim.g.netrw_preview = 1 -- Use Vertical splits
vim.g.netrw_liststyle = 3 -- Tree-style view
vim.g.netrw_winsize = 25 -- Side explorer / drawer takes 25% width
