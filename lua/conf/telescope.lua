vim.cmd.packadd { 'telescope.nvim', bang = true }
vim.cmd.packadd { 'telescope-fzf-native.nvim', bang = true }
vim.cmd.packadd { 'telescope-ui-select.nvim', bang = true }
vim.cmd.packadd { 'project.nvim', bang = true }
vim.cmd.packadd { 'nvim-notify', bang = true }

local telescope = require 'telescope'

telescope.setup {
    pickers = {
        find_files = {
            find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden', '--no-ignore-vcs' },
        },
        keymaps = {
            modes = { 'n', 'i', 'c', 'x', 'v', 'o', '', '!' },
        },
    },
    defaults = {
        mappings = {
            i = {
                ['<C-s>'] = 'select_horizontal',
                ['<C-b>'] = 'preview_scrolling_up',
                ['<C-f>'] = 'preview_scrolling_down',
                ['<C-/>'] = 'which_key',
            },
            n = {
                ['t'] = 'select_tab',
                ['s'] = 'select_horizontal',
                ['v'] = 'select_vertical',
                ['<C-b>'] = 'preview_scrolling_up',
                ['<C-f>'] = 'preview_scrolling_down',
                ['K'] = require('telescope.actions').toggle_selection
                    + require('telescope.actions').move_selection_worse,
                ['J'] = require('telescope.actions').toggle_selection
                    + require('telescope.actions').move_selection_better,
            },
        },
        layout_strategy = 'vertical',
        layout_config = {
            vertical = {
                preview_cutoff = 30,
            },
        },
        cache_picker = { num_pickers = 2, limit_entries = 100 },
        -- wrap_results = true,
    },
    extensions = {
        ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
        },
    },
}

require('telescope').load_extension 'fzf'
require('telescope').load_extension 'notify'
require('telescope').load_extension 'projects'
require('telescope').load_extension 'ui-select'

local opts = { noremap = true }
local opts_desc = function(desc)
    return {
        noremap = true,
        desc = desc,
    }
end

local keymap = vim.api.nvim_set_keymap

keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
keymap('n', '<leader>fk', '<cmd>Telescope keymaps show_plug=false<cr>', opts)

keymap('n', '<leader>fc', '<cmd>Telescope commands<cr>', opts)
keymap('n', '<leader>fC', '<cmd>Telescope command_history<cr>', opts)

keymap('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', opts)
keymap('n', '<leader>fr', '<cmd>Telescope registers<cr>', opts)
keymap('n', '<leader>fj', '<cmd>Telescope jumplist<cr>', opts)
keymap('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', opts)
keymap('n', '<leader>fT', '<cmd>Telescope treesitter<cr>', opts)
keymap('n', '<leader>ft', '<cmd>Telescope tags<cr>', opts)
keymap('n', '<leader>fm', '<cmd>Telescope marks<cr>', opts)

keymap('n', '<leader>F', '<cmd>Telescope builtin include_extensions=true<cr>', opts_desc 'Telescope extensions')
keymap('n', '<leader>fe', '<cmd>Telescope builtin include_extensions=true<cr>', opts_desc 'Telescope extensions')
keymap('n', '<A-x>', '<cmd>Telescope commands<cr>', opts_desc 'Telescope extensions')

local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local bufmap = vim.api.nvim_buf_set_keymap

autocmd('FileType', {
    pattern = 'TelescopePrompt',
    group = my_augroup,
    callback = function()
        bufmap(0, 'i', '<C-k>', '<ESC>ld$i', {})
        bufmap(0, 'i', '<C-u>', '<C-u>', {})
    end,
    desc = 'Set C-k works correctly in Telescope Prompt',
})
