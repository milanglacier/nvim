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
            return vim.api.nvim_win_get_width(0) > width
        end
    end

    local function comp_of_max_width(name, width)
        -- if the column of the current window is less than
        -- the given width, this component will not be displayed
        return { name, cond = min_window_width(width) }
    end

    local function treesitter_statusline()
        local winwidth = vim.api.nvim_win_get_width(0)
        local entire_width = vim.o.columns
        local size

        if vim.o.laststatus ~= 3 then
            if winwidth >= entire_width * 0.75 then
                size = math.floor(winwidth * 0.5)
            elseif winwidth >= entire_width * 0.45 then
                size = math.floor(winwidth * 0.25)
            else
                size = math.floor(winwidth * 0.3)
            end
        elseif vim.o.laststatus == 3 then
            size = vim.o.columns * 0.7
        end

        local ts_status = require('nvim-treesitter').statusline {
            indicator_size = size,
            separator = '  ',
        }

        ts_status = ts_status:gsub('%s+', ' ')
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
            -- globalstatus = true,
        },
        sections = {
            lualine_a = { shorten_mode_name },
            lualine_b = {
                comp_of_max_width('branch', 60),
                comp_of_max_width('diff', 80),
                'diagnostics',
            },
            lualine_c = { 'filename', treesitter_statusline },
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
        extensions = { 'aerial', 'nvim-tree', 'quickfix', 'toggleterm' },
    }
end

M.load.luatab = function()
    vim.cmd [[packadd! luatab.nvim]]
    require('luatab').setup {}
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
        { noremap = true, silent = true, desc = 'toggle background transparent' }
    )
end

M.load.trouble = function()
    vim.cmd [[packadd! trouble.nvim]]
    require('trouble').setup {
        mode = 'quickfix',
        action_keys = {
            close = 'q', -- close the list
            cancel = { '<esc>', '<c-e>' }, -- cancel the preview and get back to your last window / buffer / cursor
            refresh = 'r', -- manually refresh
            jump = { '<cr>', '<tab>' }, -- jump to the diagnostic or open / close folds
            open_split = { '<c-x>', '<c-s>' }, -- open buffer in new split
            open_vsplit = { '<c-v>' }, -- open buffer in new vsplit
            open_tab = { '<c-t>' }, -- open buffer in new tab
            jump_close = { 'o' }, -- jump to the diagnostic and close the list
            toggle_mode = 'm', -- toggle between "workspace" and "document" diagnostics mode
            toggle_preview = 'P', -- toggle auto_preview
            hover = { 'K', 'gh' }, -- opens a small popup with the full multiline message
            preview = 'p', -- preview the diagnostic location
            close_folds = { 'zM', 'zm' }, -- close all folds
            open_folds = { 'zR', 'zr' }, -- open all folds
            toggle_fold = { 'zA', 'za' }, -- toggle fold of current file
            previous = 'k', -- preview item
            next = 'j', -- next item
        },
    }

    local keymap = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }

    keymap('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', opts)
    keymap('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', opts)
    keymap('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', opts)
    keymap('n', '<leader>xq', [[<cmd>lua require 'conf.ui'.reopen_qflist_by_trouble()<cr>]], opts)
    keymap('n', '<leader>xr', '<cmd>TroubleToggle lsp_references<cr>', opts)
end

M.load.incline = function()
    vim.cmd [[packadd! incline.nvim]]

    if vim.o.laststatus ~= 3 then
        return
    end

    local incline_setup_table = {
        highlight = {
            groups = {
                InclineNormal = 'lualine_a_normal',
                InclineNormalNC = 'lualine_a_normal',
            },
        },
        hide = {
            focused_win = true,
        },
        window = {
            width = 'fill',
            placement = {
                vertical = 'bottom',
                horizontal = 'center',
            },
            margin = {
                horizontal = {
                    left = 0,
                    right = 0,
                },
            },
            padding = {
                left = 1,
                right = 1,
            },
            zindex = 10,
        },
    }

    require('incline').setup(incline_setup_table)

    local autocmd = vim.api.nvim_create_autocmd
    autocmd('ColorScheme', {
        group = require('conf.builtin_extend').my_augroup,
        desc = 'reset incline highlight after loading colorscheme',
        callback = function()
            require('incline').setup(incline_setup_table)
        end,
    })
end

M.load.devicons()
M.load.lualine()
M.load.luatab()
M.load.notify()
M.load.transparent()
M.load.trouble()
-- M.load.incline()

M.reopen_qflist_by_trouble = function()
    local windows = vim.api.nvim_list_wins()

    for _, winid in ipairs(windows) do
        local bufid = vim.api.nvim_win_get_buf(winid)
        local buf_filetype = vim.api.nvim_buf_get_option(bufid, 'filetype')
        if buf_filetype == 'qf' then
            vim.api.nvim_win_close(winid, true)
        end
    end
    require('trouble').toggle 'quickfix'
end

return M
