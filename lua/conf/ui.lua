local M = {}
M.load = {}

M.load.lualine = function()
    vim.cmd.packadd { 'lualine.nvim', bang = true }
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
                'branch',
                'diff',
                'diagnostics',
            },
            lualine_c = { 'filename' },
            lualine_x = { encoding, fileformat, 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
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
    vim.cmd.packadd { 'luatab.nvim', bang = true }
    require('luatab').setup {}
end

M.load.notify = function()
    vim.cmd.packadd { 'nvim-notify', bang = true }

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
    vim.cmd.packadd { 'nvim-web-devicons', bang = true }
    require('nvim-web-devicons').setup()
end

M.load.trouble = function()
    vim.cmd.packadd { 'trouble.nvim', bang = true }
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

M.load.which_key = function()
    vim.cmd.packadd { 'which-key.nvim', bang = true }
    require('which-key').setup {
        triggers = { '<leader>', '<localleader>', 'g', 'z', ']', '[', '`', '"', [[']], '@' },
    }
end

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local set_hl = vim.api.nvim_set_hl
local highlight_link = function(opts)
    set_hl(0, opts.linked, { link = opts.linking })
end

M.winbar = function()
    local ft = vim.bo.filetype
    local ft_blacklist = {
        'toggleterm',
        'aerial',
        'NvimTree',
        'Trouble',
        'qf',
        'starter',
    }

    local ft_match_blacklist = {
        'spectre',
        'Neogit',
        'Diffview',
        'dap',
    }

    local special_icon = 'ﰨ '

    for _, filetype in pairs(ft_blacklist) do
        if ft == filetype then
            return special_icon .. ft
        end
    end

    for _, filetype in pairs(ft_match_blacklist) do
        if ft:match(filetype) then
            return special_icon .. ft
        end
    end

    local winwidth = vim.api.nvim_win_get_width(0)
    local filename = vim.fn.expand '%:.'
    local extension = vim.fn.expand '%:e'

    local filename_blacklist = {
        'term://',
        'diffview://',
    }

    for _, fname in pairs(filename_blacklist) do
        if filename == nil or filename:match(fname) then
            return special_icon .. ft
        end
    end

    local icon = require('nvim-web-devicons').get_icon_by_filetype(ft)

    if not icon then
        icon = require('nvim-web-devicons').get_icon(filename, extension)
        if not icon then
            return special_icon .. filename
        end
    end

    local winbar = icon .. ' ' .. filename

    local rest_length = winwidth - #winbar
    local is_focused = vim.api.nvim_get_current_win() == vim.api.nvim_tabpage_get_win(0)

    if rest_length > 5 and is_focused then
        local size = math.floor(rest_length * 0.8)

        local ts_status = require('nvim-treesitter').statusline {
            indicator_size = size,
            separator = '  ',
        }

        if ts_status ~= nil and ts_status ~= '' then
            ts_status = ts_status:gsub('%s+', ' ')
            winbar = winbar .. '  ' .. ts_status
        end
    end

    return winbar
end

M.load.winbar = function()
    highlight_link { linked = 'WinBar', linking = 'lualine_b_normal' }
    highlight_link { linked = 'WinBarNC', linking = 'lualine_a_normal' }

    vim.o.winbar = "%{%v:lua.require'conf.ui'.winbar()%}"

    autocmd('ColorScheme', {
        group = my_augroup,
        callback = function()
            highlight_link { linked = 'WinBar', linking = 'lualine_b_normal' }
            highlight_link { linked = 'WinBarNC', linking = 'lualine_a_normal' }
        end,
        desc = 'set hl group for winbar',
    })
end

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

M.load.devicons()
M.load.lualine()
M.load.luatab()
M.load.notify()
M.load.trouble()
M.load.which_key()
M.load.winbar()

return M
