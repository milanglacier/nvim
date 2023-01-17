local M = {}

M.load = {}

M.load.impatient = function()
    if vim.fn.has 'gui_running' == 0 then
        require('impatient').enable_profile()
    end
end

M.load.project_nvim = function()
    vim.cmd.packadd { 'project.nvim', bang = true }
    require('project_nvim').setup {
        detection_methods = { 'pattern' },
        patterns = { '.git', '.svn', 'Makefile', 'package.json', 'NAMESPACE', 'setup.py' },
        show_hidden = true,
    }

    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>fp', '<cmd>Telescope projects<CR>', { noremap = true })
end

M.load.nvim_tree = function()
    vim.cmd.packadd { 'nvim-tree.lua', bang = true }

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
        hijack_netrw = false,
    }

    local keymap = vim.api.nvim_set_keymap

    keymap('n', '<leader>et', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
    keymap('n', '<leader>ef', '<cmd>NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
    keymap('n', '<leader>er', '<cmd>NvimTreeRefresh<CR>', { noremap = true, silent = true })
end

M.load.winshift = function()
    vim.cmd.packadd { 'winshift.nvim', bang = true }
    require('winshift').setup {}
    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<Leader>wm', '<cmd>WinShift<CR>', { noremap = true, silent = true })
end

M.load.project_nvim()
M.load.nvim_tree()
M.load.winshift()

return M
