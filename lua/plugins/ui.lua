local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

return {
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        config = function()
            local lualine = require 'lualine'

            local diagnostics_sources = require('lualine.components.diagnostics.sources').sources

            local confui = require 'conf.ui'

            diagnostics_sources.get_diagnostics_in_current_root_dir = confui.get_diagnostics_in_current_root_dir

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
                            'starter',
                            'Trouble',
                            'qf',
                            'NeogitStatus',
                            'NeogitCommitMessage',
                            'NeogitPopup',
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
                extensions = { 'aerial', 'nvim-tree', 'quickfix', 'toggleterm' },
            }
        end,
    },
    {
        'rcarriga/nvim-notify',
        event = 'VeryLazy',
        init = function()
            keymap('n', '<leader>fn', '<cmd>Telescope notify<cr>', opts)
        end,
        config = function()
            vim.notify = require 'notify'

            require('notify').setup {
                max_width = 45,
                max_height = 20,
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
            local function opt(desc, callback)
                return { silent = true, desc = desc, noremap = true, callback = callback }
            end

            keymap('n', '<leader>xw', '', opt('Workspace dianostics', require('conf.ui').trouble_workspace_diagnostics))
            keymap('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', opt 'Document Diagnostics')
            keymap('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', opt 'Open loclist')
            keymap(
                'n',
                '<leader>xq',
                [[<cmd>lua require 'conf.ui'.reopen_qflist_by_trouble()<cr>]],
                opt 'Open quickfix'
            )
            keymap(
                'n',
                '<leader>xr',
                '<cmd>Trouble lsp toggle focus=false win.position=bottom<cr>',
                opt 'Lsp reference'
            )
        end,
    },
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            local which_key = require 'which-key'
            which_key.setup {}

            which_key.add {
                { '<Leader>f', group = '+find everything', mode = { 'n', 'v' } },
                { '<Leader>d', group = '+debugger' },
                { '<Leader>b', group = '+buffer' },
                { '<Leader>w', group = '+window' },
                { '<Leader>e', group = '+explorer' },
                { '<Leader>t', group = '+terminal/toggle' },
                { '<Leader>s', group = '+search/replace', mode = { 'n', 'v' } },
                { '<Leader>o', group = '+open/org' },
                { '<Leader>ol', group = '+open/links' },
                { '<Leader>g', group = '+git', mode = { 'n', 'v' } },
                { '<Leader>gt', group = '+telescope' },
                { '<Leader>x', group = '+quickfixlist' },
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

            autocmd('LSPAttach', {
                group = my_augroup,
                desc = 'add which key description for lsp',
                callback = function(args)
                    which_key.add {
                        { '<Leader>l', group = '+lsp', buffer = args.buf, mode = { 'n', 'v' } },
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
