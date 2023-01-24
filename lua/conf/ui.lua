local M = {}
M.load = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

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

    local lualine = require 'lualine'

    lualine.setup {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = {},
            always_divide_middle = false,
        },
        sections = {
            lualine_a = { shorten_mode_name },
            lualine_b = {
                'branch',
                {
                    M.get_workspace_diff,
                    cond = function()
                        return M.get_workspace_diff() ~= nil
                    end,
                }, -- "" will be nil in lualine
            },
            lualine_c = { { 'filename', path = 1 } }, -- relative path
            lualine_x = {
                { 'diagnostics', sources = { 'nvim_workspace_diagnostic' } },
                encoding,
                fileformat,
                'filetype',
            },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
        },
        tabline = {
            lualine_a = {
                { 'filetype', icon_only = true },
            },
            lualine_b = { { 'tabs', mode = 2, max_length = vim.o.columns } },
        },
        winbar = {
            lualine_b = {
                { 'filetype', icon_only = true },
                { 'filename', path = 0 },
            },
            lualine_c = { M.winbar_symbol },
            lualine_x = {
                function()
                    return ' '
                end, -- this is to avoid annoying highlight (high contrast color)
                { 'diagnostics', sources = { 'nvim_diagnostic' } },
                'diff',
            },
        },
        inactive_winbar = {
            lualine_a = {
                { 'filetype', icon_only = true },
                { 'filename', path = 0 },
            },
            lualine_x = {
                { 'diagnostics', sources = { 'nvim_diagnostic' } },
                'diff',
            },
        },
        extensions = { 'aerial', 'nvim-tree', 'quickfix', 'toggleterm' },
    }

    lualine.hide {
        place = { 'tabline' },
        unhide = false,
    } -- disable tabline when init nvim

    autocmd('TabNew', {
        group = my_augroup,
        desc = 'init lualine tabline',
        callback = function()
            lualine.hide {
                place = { 'tabline' },
                unhide = true,
            }
        end,
    })
    autocmd('TabClosed', {
        group = my_augroup,
        desc = 'toggle lualine tabline',
        callback = function()
            if #vim.api.nvim_list_tabpages() < 2 then
                lualine.hide {
                    place = { 'tabline' },
                    unhide = false,
                }
            end
        end,
    })
end

M.git_workspace_diff = {}

M.set_git_workspace_diff = function()
    local function is_a_git_dir()
        local is_git = vim.fn.system 'git rev-parse --is-inside-work-tree' == 'true\n'
        return is_git
    end

    local function compute_workspace_diff()
        local changes = vim.fn.system [[git diff --stat | tail -n 1]]
        changes = string.sub(changes, 1, -2) -- the last character is \n, remove it
        changes = vim.split(changes, ',')

        local change_add_del = {}
        for _, i in pairs(changes) do
            if i:find 'change' then
                change_add_del.file_changed = i:match '(%d+)'
            elseif i:find 'insertion' then
                change_add_del.added = i:match '(%d+)'
            elseif i:find 'deletion' then
                change_add_del.removed = i:match '(%d+)'
            end
        end

        return change_add_del
    end

    local function init_workspace_diff()
        local cwd = vim.fn.getcwd()

        if M.git_workspace_diff[cwd] == nil then
            if is_a_git_dir() then
                M.git_workspace_diff[cwd] = compute_workspace_diff()
            end
        end
    end

    local function update_workspace_diff()
        local cwd = vim.fn.getcwd()
        if M.git_workspace_diff[cwd] ~= nil then
            M.git_workspace_diff[cwd] = compute_workspace_diff()
        end
    end

    autocmd('BufEnter', {
        group = my_augroup,
        desc = 'Init the git diff',
        callback = function()
            vim.defer_fn(function()
                init_workspace_diff()
                -- defer this function because project root need to be updated.
            end, 500)
        end,
    })
    autocmd('BufWritePost', {
        group = my_augroup,
        desc = 'Update the git diff',
        callback = function()
            vim.defer_fn(function()
                update_workspace_diff()
            end, 100)
        end,
    })
end

M.get_workspace_diff = function()
    if vim.fn.expand('%:p'):find(vim.fn.getcwd()) then
        -- if the absolute path of current file is a sub directory of pwd
        local current_diff = M.git_workspace_diff[vim.fn.getcwd()]
        if current_diff == nil then
            return ''
        end

        if current_diff ~= nil and vim.tbl_count(current_diff) > 0 then
            local diff_string = ' '
            if current_diff.file_changed ~= nil then
                diff_string = diff_string .. ' ' .. current_diff.file_changed
            end
            if current_diff.added ~= nil then
                diff_string = diff_string .. ' +' .. current_diff.added
            end
            if current_diff.removed ~= nil then
                diff_string = diff_string .. ' -' .. current_diff.removed
            end
            return diff_string
        end
    else
        return ''
    end
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
    local which_key = require 'which-key'
    which_key.setup {
        triggers = { '<leader>', '<localleader>', 'g', 'z', ']', '[', '`', '"', [[']], '@' },
    }

    which_key.register {
        ['<Leader>f'] = { name = '+find everything' },
        ['<Leader>l'] = { name = '+language server' },
        ['<Leader>d'] = { name = '+debugger' },
        ['<Leader>b'] = { name = '+buffer' },
        ['<Leader>w'] = { name = '+window' },
        ['<Leader>e'] = { name = '+explorer' },
        ['<Leader>t'] = { name = '+terminal' },
        ['<Leader>o'] = { name = '+open/org' },
        ['<Leader>ol'] = { name = '+open/links' },
        ['<Leader>g'] = { name = '+git' },
        ['<Leader>x'] = { name = '+quickfixlist' },
        ['<Leader><Tab>'] = { name = '+tab' },
        ['<Leader><space>'] = { name = '+local leader' },
        ['<Leader>m'] = { name = '+misc' },
        ['<Leader>mm'] = { name = '+markdown' },
        ['<Leader>md'] = { name = '+change directory' },
        ['<Leader><Space>r'] = { name = '+REPL' },
        ['<Leader><Space>s'] = { name = '+send to REPL(motion)' },
        [']<Space>'] = { name = '+Additional motions' },
        [']<Space>l'] = { name = '+latex motions' },
        ['[<Space>'] = { name = '+Additional motions' },
        ['[<Space>l'] = { name = '+latex motions' },
    }

    which_key.register({
        ['<Leader>l'] = { name = '+language server' },
        ['<Leader>f'] = { name = '+find everything' },
        ['<Leader><space>'] = { name = '+local leader' },
        ['<LocalLeader>s'] = { name = 'send to REPL' },
    }, { mode = 'v' })

    autocmd('FileType', {
        group = my_augroup,
        pattern = 'org',
        desc = 'add which key description for org',
        callback = function()
            which_key.register {
                ['<Leader>oi'] = { name = '+org insert', buffer = 0 },
                ['<Leader>ox'] = { name = '+org clock', buffer = 0 },
            }
        end,
    })

    autocmd('FileType', {
        group = my_augroup,
        pattern = { 'r', 'rmd', 'quarto' },
        desc = 'add which key description for r, rmd, quarto',
        callback = function()
            which_key.register {
                ['<Leader><Space>d'] = { name = '+data frame', buffer = 0 },
                ['<Leader><Space>o'] = { name = '+object', buffer = 0 },
            }
        end,
    })

    autocmd('FileType', {
        group = my_augroup,
        pattern = 'tex',
        desc = 'add which key description for tex',
        callback = function()
            which_key.register {
                ['<Leader><Space>l'] = { name = '+vimtex', buffer = 0 },
                ['<Leader><Space>s'] = { name = '+vimtex surround', buffer = 0 },
                ['<Leader><Space>t'] = { name = '+vimtex toggle', buffer = 0 },
                ['<Leader><Space>c'] = { name = 'vimtex create cmd', buffer = 0 },
            }
            which_key.register({
                ['<Leader><Space>s'] = { name = '+vimtex surround', buffer = 0 },
                ['<Leader><Space>t'] = { name = '+vimtex toggle', buffer = 0 },
                ['<Leader><Space>c'] = { name = 'vimtex create cmd', buffer = 0 },
            }, { mode = 'v' })
        end,
    })
end

M.winbar_symbol = function()
    vim.cmd.packadd { 'nvim-navic', bang = true }
    local navic = require 'nvim-navic'

    if navic.is_available() then
        return navic.get_location()
    end

    local winwidth = vim.api.nvim_win_get_width(0)
    local filename = vim.fn.expand '%:.'

    local winbar = filename

    local rest_length = winwidth - #winbar - 3
    local ts_status = ''

    if rest_length > 5 then
        local size = math.floor(rest_length * 0.8)

        ts_status = require('nvim-treesitter').statusline {
            indicator_size = size,
            separator = '  ',
        } or ''

        if ts_status ~= nil and ts_status ~= '' then
            ts_status = ts_status:gsub('%s+', ' ')
        end
    end

    return ts_status
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
M.load.notify()
M.load.trouble()
M.load.which_key()
M.set_git_workspace_diff()

return M
