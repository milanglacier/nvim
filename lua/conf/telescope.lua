vim.cmd [[packadd! telescope.nvim]]
vim.cmd [[packadd! telescope-fzf-native.nvim]]
vim.cmd [[packadd! telescope-ui-select.nvim]]
vim.cmd [[packadd! project.nvim]]
vim.cmd [[packadd! nvim-notify]]

local telescope = require 'telescope'

telescope.setup {
    pickers = {
        find_files = {
            find_command = { 'rg', '--files', '--iglob', '!.git', '--hidden' },
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

local keymap = vim.api.nvim_set_keymap

keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
keymap('n', '<leader>fk', '<cmd>Telescope keymaps<cr>', opts)

keymap('n', '<leader>fc', '<cmd>Telescope commands<cr>', opts)
keymap('n', '<leader>fC', '<cmd>Telescope command_history<cr>', opts)

keymap('n', '<leader>ft', '<cmd>Telescope treesitter<cr>', opts)
keymap('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', opts)
keymap('n', '<leader>fr', '<cmd>Telescope registers<cr>', opts)
keymap('n', '<leader>fj', '<cmd>Telescope jumplist<cr>', opts)
keymap('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', opts)

keymap('n', '<leader>F', '<cmd>Telescope builtin include_extensions=true<cr>', opts)
