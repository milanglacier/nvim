local M = {}
M.load = {}

M.load.lualine = function()
    vim.cmd [[packadd! lualine.nvim]]
    -- Override 'encoding': Don't display if encoding is UTF-8.
    local encoding = function()
        local ret, _ = (vim.bo.fenc or vim.go.enc):gsub('^utf%-8$', '')
        return ret
    end

    local fileformat = function()
        local ret, _ = vim.bo.fileformat:gsub('^unix$', '')
        if ret == 'dos' then
            ret = ''
        end
        return ret
    end

    local mode_remap = {
        ['NORMAL'] = 'N',
        ['O-PENDING'] = 'OP',
        ['VISUAL'] = 'V',
        ['V-LINE'] = 'V-L',
        ['V-BLOCK'] = 'V-B',
        ['SELECT'] = 'S',
        ['S-LINE'] = 'S-L',
        ['S-BLOCK'] = 'S-B',
        ['INSERT'] = 'I',
        ['REPLACE'] = 'R',
        ['V-REPLACE'] = 'V-R',
        ['COMMAND'] = 'C',
        ['EX'] = 'EX',
        ['MORE'] = 'MORE',
        ['CONFIRM'] = '✓',
        ['SHELL'] = 'SH',
        ['TERMINAL'] = 'TERM',
    }

    local shorten_mode_name = function()
        local mode = require 'lualine.components.mode'()
        return mode_remap[mode] or mode
    end

    local function min_window_width(width)
        return function()
            return vim.fn.winwidth(0) > width
        end
    end

    local function comp_of_max_width(name, width)
        -- if the column of the current window is less than
        -- the given width, this component will not be displayed
        return { name, cond = min_window_width(width) }
    end

    local function treesitter_statusline()
        local size = 80

        local ts_status = vim.fn['nvim_treesitter#statusline'] {
            indicator_size = size,
            separator = '  ',
        }

        if ts_status == vim.NIL then
            ts_status = ''
        end
        return ts_status
    end

    require('lualine').setup {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {},
            always_divide_middle = false,
        },
        sections = {
            lualine_a = { shorten_mode_name },
            lualine_b = {
                comp_of_max_width('branch', 60),
                comp_of_max_width('diff', 80),
                'diagnostics',
            },
            lualine_c = { 'filename', comp_of_max_width(treesitter_statusline, 120) },
            lualine_x = { encoding, fileformat, 'filetype' },
            lualine_y = { comp_of_max_width('progress', 40) },
            lualine_z = { comp_of_max_width('location', 60) },
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { { 'filename', path = 1, shorting_target = 20 } }, -- relative path
            lualine_x = { 'progress', 'location' },
            lualine_y = {},
            lualine_z = {},
        },
        tabline = {},
        extensions = { 'aerial', 'nvim-tree', 'quickfix' },
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
        'n',
        '<LocalLeader>bt',
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
