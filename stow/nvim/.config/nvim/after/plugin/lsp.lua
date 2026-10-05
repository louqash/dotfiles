-- LSP setup using the native vim.lsp.config/vim.lsp.enable API (Neovim 0.11+).
-- nvim-lspconfig is still installed for its per-server default configs (lsp/ dir);
-- its old require('lspconfig') framework is deprecated and no longer used here.
-- mason-lspconfig v2 auto-enables the selected mason-installed servers via vim.lsp.enable().

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

    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    elseif client.name == "pyrefly" then
      -- Ruff owns Python formatting.
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    -- clangd-specific niceties for C/C++ development
    if client.name == "clangd" then
      -- jump between the .cpp/.h(pp) counterparts of the current file
      vim.keymap.set("n", "<leader>ch", "<cmd>LspClangdSwitchSourceHeader<cr>", opts)
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

vim.lsp.config('pyrefly', {
  before_init = function(_, config)
    local python = require('louqash.python_util').get_python_executable(config.root_dir)
    if python then
      config.init_options = vim.tbl_deep_extend('force', config.init_options or {}, {
        pythonPath = python,
      })
      config.settings = vim.tbl_deep_extend('force', config.settings or {}, {
        python = { pythonPath = python },
      })
    end
  end,
})

vim.lsp.config('ruff', {})

require('mason').setup({})
require('mason-lspconfig').setup({
  -- Use the server's system clangd; Mason supplies the Python tools.
  ensure_installed = { 'pyrefly', 'ruff' },
  automatic_enable = { 'clangd', 'pyrefly', 'ruff' },
})

-- Also enable servers installed on PATH, including the system clangd.
vim.lsp.enable({ 'clangd', 'pyrefly', 'ruff' })

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
