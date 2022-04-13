local M = {}
M.load = {}

M.load.lualine = function()
    vim.cmd [[packadd! lualine.nvim]]

    require('lualine').setup {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {},
            always_divide_middle = true,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { 'filename' },
            lualine_x = {
                'encoding',
                {
                    'fileformat',
                    symbols = {
                        unix = '', -- e712
                        dos = '', -- e70f
                        mac = '', -- e711
                    },
                },
                { 'filetype' },
            },
            -- icon_only = true}},
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        extensions = { 'aerial', 'nvim-tree' },
    }
end

M.load.luatab = function()
    vim.cmd [[packadd! luatab.nvim]]
    require('luatab').setup()
end

M.load.notify = function()
    vim.cmd [[packadd! nvim-notify]]

    vim.notify = require 'notify'

    require('notify').setup {
        max_width = 45,
        max_height = 20,
    }

    local opts = { noremap = true, silent = true }
    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<leader>fn', '<cmd>Telescope notify<cr>', opts)
end

M.load.devicons = function()
    vim.cmd [[packadd! nvim-web-devicons]]
    require('nvim-web-devicons').setup()
end

M.load.transparent = function()
    local keymap = vim.api.nvim_set_keymap
    keymap(
        'n', '<LocalLeader>bt',
        [[<cmd>packadd nvim-transparent | set background=dark | TransparentToggle<CR>]],
        { noremap = true, silent = true }
    )
end

M.load.devicons()
M.load.lualine()
M.load.luatab()
M.load.notify()
M.load.transparent()

return M
