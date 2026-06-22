-- nvim-treesitter `main` branch (required for Neovim 0.12+).
-- The old `nvim-treesitter.configs` module API no longer exists: parsers are
-- installed with `:TSInstall` / `.install()`, and highlighting/indentation are
-- enabled per-buffer with `vim.treesitter.start()`.

local ensure_installed = {
  "c", "python", "bash", "lua", "vim", "vimdoc", "query",
  "rust", "toml", "markdown", "markdown_inline", "just",
}

require("nvim-treesitter").install(ensure_installed)

-- Start treesitter highlighting + indentation for any buffer whose filetype
-- has an installed parser. Wrapped in pcall so filetypes without a parser
-- are silently skipped instead of erroring.
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    if not pcall(vim.treesitter.start, args.buf, lang) then
      return
    end
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
