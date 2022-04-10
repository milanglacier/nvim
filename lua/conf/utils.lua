local M = {}

M.load = {}

M.load.impatient = function()
    if vim.fn.has 'gui_running' == 0 then
        require('impatient').enable_profile()
    end
end

M.load.better_escape = function()
    vim.cmd [[packadd! better-escape.nvim]]

    require('better_escape').setup {
        mapping = { 'jk' }, -- a table with mappings to use
        timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
        clear_empty_lines = false, -- clear line after escaping if there is only whitespace
        keys = '<Esc>', -- keys used for escaping, if it is a function will use the result every time
        -- example() keys = function() return vim.api.nvim_win_get_cursor(0)[2] > 1 and '<esc>l' or '<esc>' end,
    }
end

M.load.rooter = function()
    vim.cmd [[packadd! rooter.nvim]]
end

M.load.project_nvim = function()
    vim.cmd [[packadd! project.nvim]]
    require('project_nvim').setup {}

    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>pj', '<cmd>Telescope projects<CR>', { noremap = true })
end

M.load.nvim_tree = function()
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
end

M.load.better_escape()
M.load.rooter()
M.load.project_nvim()
M.load.better_escape()
M.load.nvim_tree()

return M
