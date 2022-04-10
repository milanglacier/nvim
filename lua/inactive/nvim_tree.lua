vim.cmd [[packadd! nvim-tree.lua]]

vim.g.nvim_tree_icons = {
    default = '',
    symlink = '',
    git = {
        unstaged = '✗',
        staged = '✓',
        unmerged = '',
        renamed = '➜',
        untracked = '★',
        deleted = '',
        ignored = '◌',
    },
    folder = {
        arrow_open = '',
        arrow_closed = '',
        default = '',
        open = '',
        empty = '',
        empty_open = '',
        symlink = '',
        symlink_open = '',
    },
}

require('nvim-tree').setup {
    view = {
        mappings = {
            list = { { key = '?', action = 'toggle_help' } },
        },
    },
}

local keymap = vim.api.nvim_set_keymap

keymap('n', '<leader>tt', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
keymap('n', '<leader>tf', '<cmd>NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
keymap('n', '<leader>tr', '<cmd>NvimTreeRefresh<CR>', { noremap = true, silent = true })
