-- The frozen master branch supports the pinned Neovim 0.11 release.
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "c", "cpp", "cmake", "python", "bash", "lua", "vim", "vimdoc", "query",
    "rust", "toml", "markdown", "markdown_inline", "json", "yaml",
  },
  auto_install = false,
  highlight = { enable = true },
  indent = { enable = true },
})
