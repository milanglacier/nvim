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

M.load.project_nvim = function()
    vim.cmd [[packadd! project.nvim]]
    require('project_nvim').setup {
        detection_methods = { 'pattern' },
        patterns = { '.git', '.svn', 'Makefile', 'package.json', 'NAMESPACE', 'setup.py' },
        show_hidden = true,
    }

    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>pj', '<cmd>Telescope projects<CR>', { noremap = true })
end

M.load.nvim_tree = function()
    vim.cmd [[packadd! nvim-tree.lua]]

    require('nvim-tree').setup {
        view = {
            mappings = {
                list = { { key = '?', action = 'toggle_help' } },
            },
        },
        -- this makes nvim-tree opens in project root when switching between projects,
        -- see project.nvim's README
        respect_buf_cwd = true,
        update_cwd = true,
        update_focused_file = {
            enable = true,
            update_cwd = true,
        },
    }

    local keymap = vim.api.nvim_set_keymap

    keymap('n', '<leader>tt', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
    keymap('n', '<leader>tf', '<cmd>NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
    keymap('n', '<leader>tr', '<cmd>NvimTreeRefresh<CR>', { noremap = true, silent = true })
end

M.load.winshift = function()
    vim.cmd [[packadd! winshift.nvim]]
    require('winshift').setup {}
    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>wm', '<cmd>WinShift<CR>', { noremap = true, silent = true })
end

M.load.better_escape()
M.load.project_nvim()
M.load.better_escape()
M.load.nvim_tree()
M.load.winshift()

return M
