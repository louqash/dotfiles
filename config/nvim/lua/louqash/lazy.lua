local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
local farwork = vim.fn.expand("~/farwork.nvim")

require("lazy").setup({
  {
    "louqash/farwork.nvim",
    dir = vim.fn.isdirectory(farwork .. "/lua/farwork") == 1 and farwork or nil,
    lazy = false,
    config = function()
      require("farwork").setup({ keymaps = true, auto_connect = true, auto_commit = true })
    end,
  },
  {
    "maxmx03/solarized.nvim",
    priority = 1000,
    config = function()
      require("solarized").setup()
    end,
  },
  {
    'nvim-telescope/telescope.nvim', tag = 'v0.2.2',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
  },
  'mbbill/undotree',
  'tpope/vim-fugitive',
  'mtdl9/vim-log-highlighting',
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
      follow_cursor = true, -- preview scrolls to follow the editor cursor
      -- Use brew-installed binaries (see Brewfile) instead of the plugin's
      -- default behavior of downloading prebuilt binaries at build time.
      dependencies_bin = {
        ["tinymist"] = "tinymist",
        ["websocat"] = "websocat",
      },
    },
  },
  {'williamboman/mason.nvim'},
  {'williamboman/mason-lspconfig.nvim'},
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/cmp-nvim-lsp'},
  {'hrsh7th/cmp-path'},
  {'hrsh7th/cmp-nvim-lua'},
  {'hrsh7th/nvim-cmp'},
  {'saadparwaiz1/cmp_luasnip'},
  {'ray-x/lsp_signature.nvim'},
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
        require("nvim-surround").setup({})
    end
  },
  {
    'chrisgrieser/nvim-justice',
  },
  {
    'Julian/lean.nvim',
    event = { 'BufReadPre *.lean', 'BufNewFile *.lean' },
    dependencies = {
      'neovim/nvim-lspconfig',
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    opts = {
      mappings = true,
    },
  }
})
