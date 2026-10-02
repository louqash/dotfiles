local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
-- Grep for the current visual selection.
vim.keymap.set('x', '<leader>ps', function()
	local save = vim.fn.getreg('v')
	local save_type = vim.fn.getregtype('v')
	vim.cmd('noautocmd normal! "vy')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', save, save_type)
	builtin.grep_string({ search = text })
end)

require("telescope").setup { 
    pickers = {
        current_buffer_fuzzy_find = { sorting_strategy = 'ascending' },
        find_files = {
            find_command = {
                'rg',
                '--files',
                '--color', 'never',
                '--hidden',
                '--glob',
                '!{**/.git/*,**/node_modules/*,**/package-lock.json,**/yarn.lock}',
            },
        },
        live_grep = {
            additional_args = function(opts)
                return {
                    '--hidden',
                    '--color', 'never',
                    '--glob',
                    '!{**/.git/*,**/node_modules/*,**/package-lock.json,**/yarn.lock}',
                }
            end
        },
    },
}
