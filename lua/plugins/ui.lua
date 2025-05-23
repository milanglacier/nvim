local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local keymap = vim.api.nvim_set_keymap

---@param desc? string
---@param callback? fun()
---@return table
local function opts(desc, callback)
    return { silent = true, desc = desc, noremap = true, callback = callback }
end

return {
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        config = function()
            local lualine = require 'lualine'

            local diagnostics_sources = require('lualine.components.diagnostics.sources').sources

            local confui = require 'conf.ui'

            diagnostics_sources.get_diagnostics_in_current_root_dir = confui.get_diagnostics_in_current_root_dir

            -- HACK: see lualine.nvim issue #1201, Illegal character from fzf
            -- may hang lualine. We disable lualine from trying to get the
            -- content from current selected item from fzf to avoid invalid
            -- character.
            require('lualine.extensions.fzf').sections.lualine_y = {}

            lualine.setup {
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    always_divide_middle = false,
                    always_show_tabline = false,
                    disabled_filetypes = {
                        winbar = {
                            'aerial',
                            'NvimTree',
                            'neo-tree',
                            'starter',
                            'Trouble',
                            'qf',
                            'NeogitStatus',
                            'NeogitCommitMessage',
                            'NeogitPopup',
                            'dap-view',
                            'dap-view-term',
                            'dap-repl',
                        },
                        statusline = {
                            'starter',
                        },
                    },
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = {
                        'branch',
                        confui.project_name,
                        confui.get_workspace_diff,
                    },
                    lualine_c = { { 'filename', path = 1, symbols = confui.file_status_symbol }, { 'searchcount' } }, -- relative path
                    lualine_x = {
                        confui.macro_status,
                        { 'diagnostics', sources = { 'get_diagnostics_in_current_root_dir' } },
                        confui.encoding,
                        confui.fileformat,
                        'filetype',
                    },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' },
                },
                tabline = {
                    lualine_a = {
                        { 'filetype', icon_only = true },
                    },
                    lualine_b = {
                        { 'tabs', mode = 2, max_length = vim.o.columns },
                    },
                },
                winbar = {
                    lualine_a = {
                        { 'filetype', icon_only = true },
                        { 'filename', path = 0, symbols = confui.file_status_symbol },
                    },
                    lualine_c = { confui.winbar_symbol },
                    lualine_x = {
                        function()
                            return ' '
                        end,
                        -- this is to avoid annoying highlight (high contrast color)
                        -- when no winbar_symbol, diagnostics and diff is available.
                        { 'diagnostics', sources = { 'nvim_diagnostic' } },
                        'diff',
                    },
                },
                inactive_winbar = {
                    lualine_a = {
                        { 'filetype', icon_only = true },
                        { 'filename', path = 0, symbols = confui.file_status_symbol },
                    },
                    lualine_x = {
                        { 'diagnostics', sources = { 'nvim_diagnostic' } },
                        'diff',
                    },
                },
                extensions = { 'aerial', 'neo-tree', 'quickfix', 'toggleterm', 'fzf' },
            }
        end,
    },
    {
        'folke/snacks.nvim',
        event = 'VeryLazy',
        init = function()
            keymap('n', '<leader>fn', '<cmd>lua Snacks.notifier.show_history()<cr>', opts 'Notification History')
        end,
        config = function()
            require('snacks').setup {
                notifier = { enabled = true, timeout = 2000 },
            }
        end,
    },
    {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        config = function()
            require('trouble').setup {}
        end,
        init = function()
            local ui = require 'conf.ui'
            keymap('n', '<leader>xw', '', opts('Workspace dianostics', ui.trouble_workspace_diagnostics))
            keymap('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', opts 'Document Diagnostics')
            keymap('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', opts 'Open loclist')
            keymap('n', '<leader>xq', '', opts('Open quickfix', ui.reopen_qflist_by_trouble))
            keymap(
                'n',
                '<leader>xr',
                '<cmd>Trouble lsp toggle focus=false win.position=bottom<cr>',
                opts 'Lsp reference'
            )
        end,
    },
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            local which_key = require 'which-key'
            which_key.setup {
                triggers = {
                    { '<auto>', mode = 'nso' },
                },
            }

            which_key.add {
                { '<Leader>f', group = '+find', mode = { 'n', 'v' } },
                { '<Leader>d', group = '+debugger' },
                { '<Leader>b', group = '+buffer' },
                { '<Leader>l', group = '+lsp', mode = { 'n', 'v' } },
                { '<Leader>w', group = '+window' },
                { '<Leader>e', group = '+explorer' },
                { '<Leader>t', group = '+terminal/toggle' },
                { '<Leader>s', group = '+search/replace', mode = { 'n', 'v' } },
                { '<Leader>o', group = '+open/org' },
                { '<Leader>ol', group = '+open/links' },
                { '<Leader>g', group = '+git', mode = { 'n', 'v' } },
                { '<Leader>gm', group = '+misc' },
                { '<Leader>x', group = '+qf' },
                { '<Leader>a', group = '+aider', mode = { 'n', 'v' } },
                { '<Leader>c', group = '+chat', mode = { 'n', 'v' } },
                { '<Leader><Tab>', group = '+tab' },
                { '<Leader>m', group = '+misc', mode = { 'n', 'v' } },
                { '<Leader>mm', group = '+markdown' },
                { '<Leader>md', group = '+change directory' },
            }

            local keymap_for_repl = {
                { '<Leader><Space>', group = '+localleader', buffer = 0 },
                { '<Leader><Space>r', group = '+REPL', buffer = 0 },
                { '<Leader><Space>s', group = '+send to REPL(motion)', buffer = 0, mode = { 'n', 'v' } },
            }

            autocmd('FileType', {
                group = my_augroup,
                pattern = 'org',
                desc = 'add which key description for org',
                callback = function()
                    which_key.add {
                        { '<Leader><Space>', group = '+localleader', buffer = 0 },
                        { '<Leader>oi', group = '+org insert', buffer = 0 },
                        { '<Leader>ox', group = '+org clock', buffer = 0 },
                    }
                end,
            })

            autocmd('FileType', {
                group = my_augroup,
                pattern = 'tex',
                desc = 'add which key description for tex',
                callback = function()
                    which_key.add {
                        { '<Leader><Space>l', group = '+vimtex', buffer = 0 },
                        { '<Leader><Space>s', group = '+vimtex surround', buffer = 0 },
                        { '<Leader><Space>t', group = '+vimtex toggle', buffer = 0 },
                        { '<Leader><Space>c', group = 'vimtex create cmd', buffer = 0 },
                    }
                end,
            })

            autocmd('FileType', {
                pattern = { 'quarto', 'markdown', 'rmd', 'python', 'r', 'sh', 'REPL' },
                group = my_augroup,
                desc = 'Add which key description for REPL',
                callback = function()
                    which_key.add(keymap_for_repl)
                end,
            })
        end,
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        event = 'LazyFile',
        config = function()
            require('ibl').setup {
                indent = {
                    char = '┆',
                },
                scope = {
                    show_start = false,
                    show_end = false,
                    priority = 1,
                    highlight = { 'Type' },
                    include = {
                        node_type = {
                            ['*'] = { 'if_statement', 'for_statement', 'while_statement' },
                            -- TODO: Honestly, I only care about CURRENT INDENTATION
                            -- LEVEL. I have no idea why the author reimplemented
                            -- everything. the concept of "scope" is particularly
                            -- baffling. it brings nothing but leads to a lot of
                            -- annoyoing things. Thus, I need to add more nodes to be
                            -- considered as scope to mimic "CURRENT INDENTATION LEVEL"
                            -- behavior.
                        },
                    },
                },
            }
        end,
    },
    {
        'kyazdani42/nvim-web-devicons',
        config = function()
            return require('nvim-web-devicons').setup {}
        end,
    },
}
