local M = {}

M.load = {}

M.load.project_nvim = function()
    require('project_nvim').setup {
        detection_methods = { 'pattern' },
        patterns = { '.git', '.svn', 'Makefile', 'package.json', 'NAMESPACE', 'setup.py' },
        show_hidden = true,
    }

    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>fp', '<cmd>Telescope projects<CR>', { noremap = true })
end

M.load.nvim_tree = function()
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
        git = {
            ignore = false,
        },
    }

    local keymap = vim.api.nvim_set_keymap

    keymap('n', '<leader>et', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
    keymap('n', '<leader>ef', '<cmd>NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
    keymap('n', '<leader>er', '<cmd>NvimTreeRefresh<CR>', { noremap = true, silent = true })
end

M.load.winshift = function()
    require('winshift').setup {}
    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>wm', '<cmd>WinShift<CR>', { noremap = true, silent = true })
end

M.load.project_nvim()
M.load.nvim_tree()
M.load.winshift()

return M
