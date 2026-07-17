-- LSP setup using the native vim.lsp.config/vim.lsp.enable API (Neovim 0.11+).
-- nvim-lspconfig is still installed for its per-server default configs (lsp/ dir);
-- its old require('lspconfig') framework is deprecated and no longer used here.
-- mason-lspconfig v2 auto-enables every mason-installed server via vim.lsp.enable().

local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')
local luasnip = require('luasnip')

require('luasnip.loaders.from_vscode').lazy_load()

local capabilities = cmp_lsp.default_capabilities()

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local bufnr = args.buf
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("n", "<leader>vf", function() vim.lsp.buf.format() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

    -- Auto-show a floating signature popup while typing inside "(...)" — shows the
    -- active parameter and lets you cycle overloads (e.g. all std::vector ctors)
    -- with <C-j>. Attached per-buffer here so it hooks every LSP buffer reliably.
    local ok_sig, lsp_signature = pcall(require, "lsp_signature")
    if ok_sig then
      lsp_signature.on_attach({
        bind = true,
        hint_enable = false,               -- no inline virtual-text hint; use the popup
        floating_window = true,
        handler_opts = { border = "rounded" },
        select_signature_key = "<C-j>",    -- cycle through overloads
      }, bufnr)
    end

    -- clangd-specific niceties for C/C++ development
    if client.name == "clangd" then
      -- jump between the .cpp/.h(pp) counterparts of the current file
      vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
    end
  end,
})

-- Defaults merged into every server config.
vim.lsp.config('*', {
  capabilities = capabilities,
})

-- clangd (C/C++). clangd only speaks utf-8/utf-16; pin utf-16 to match
-- Neovim/nvim-cmp and silence the "multiple offset_encodings" warning.
vim.lsp.config('clangd', {
  capabilities = {
    offsetEncoding = { "utf-16" },
  },
  cmd = {
    "clangd",
    "--background-index",       -- index the whole project in the background
    "--clang-tidy",             -- run clang-tidy diagnostics inline
    "--header-insertion=iwyu",  -- auto-add #includes (include-what-you-use)
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",    -- format style when no .clang-format is found
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
})

vim.lsp.config('pylsp', {
  on_init = function(client)
    local python_utils = require('louqash.python_util')
    if python_utils.is_poetry_installed() then
      local poetry_env = python_utils.get_poetry_project_path()
      if poetry_env then
        client.config.settings.pylsp.plugins.jedi.environment = poetry_env
        local pylint_args = string.format("--init-hook='import sys; sys.path.append(\"%s\")'", python_utils.get_poetry_site_packages())
        table.insert(client.config.settings.pylsp.plugins.pylint.args, pylint_args)
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        return true
      end
    end
  end,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        flake8 = { enabled = false, maxLineLength = 120 },
        pyflakes = { enabled = false, maxLineLength = 120 },
        ruff = { enabled = true },
        mccabe = { enabled = false },
        pylint = { enabled = false, args = {}},
        jedi_signature_help = { enabled = true },
        jedi_completion = {
          include_params = true,
          fuzzy = true,
        },
        jedi = {
          extra_paths = {},
        },
      },
    },
  },
})

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = { 'clangd' },
})

-- mason-lspconfig enables mason-installed servers automatically; enable clangd
-- explicitly too so a system clangd on PATH works on machines without the
-- mason-managed one.
vim.lsp.enable('clangd')

local cmp_select = {behavior = cmp.SelectBehavior.Select}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = {
    {name = 'path'},
    {name = 'nvim_lsp'},
    {name = 'nvim_lua'},
    {name = 'luasnip'},
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
  }),
  completion = {
    autocomplete = {
      require('cmp.types').cmp.TriggerEvent.TextChanged,
    },
    completeopt = 'menu,menuone,noinsert',
  },
})

vim.keymap.set({'i', 's'}, '<C-k>', function()
  if luasnip.locally_jumpable(1) then luasnip.jump(1) end
end, {silent = true})

vim.keymap.set({'i', 's'}, '<C-j>', function()
  if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
end, {silent = true})
