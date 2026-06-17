local lspconfig = require('lspconfig')
local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')
local luasnip = require('luasnip')

require('luasnip.loaders.from_vscode').lazy_load()

local capabilities = cmp_lsp.default_capabilities()

local on_attach = function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,
    pylsp = function()
      local python_utils = require('louqash.python_util')
      lspconfig.pylsp.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        on_init = function(client)
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
        }
      })
    end,
  }
})

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
    ['<C-e>'] = cmp.mapping.complete(),
  }),
  completion = {
    autocomplete = {
      require('cmp.types').cmp.TriggerEvent.TextChanged,
    },
    completeopt = 'menu,menuone,noinsert',
  },
})
