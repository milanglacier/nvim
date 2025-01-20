local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufmap = vim.api.nvim_buf_set_keymap

return {
    -- an installer for a bunch of CLI tools (e.g. LSP, linters)
    {
        'williamboman/mason.nvim',
        cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall' },
        config = function()
            require('mason').setup()
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        cmd = 'ToggleTerm',
        config = function()
            require('toggleterm').setup {
                -- size can be a number or function which is passed the current terminal
                size = function(term)
                    if term.direction == 'horizontal' then
                        return 15
                    elseif term.direction == 'vertical' then
                        return vim.o.columns * 0.30
                    end
                end,
                open_mapping = [[<Leader>ot]],
                shade_terminals = false,
                start_in_insert = false,
                insert_mappings = false,
                terminal_mappings = false,
                persist_size = true,
                direction = 'horizontal',
                close_on_exit = true,
            }
        end,
        init = function()
            keymap('n', '<Leader>ot', '<cmd>exe v:count . "ToggleTerm"<CR>', { desc = 'Toggle display all terminals' })
            keymap(
                'n',
                '<Leader>t!',
                [[<cmd>execute v:count . "TermExec cmd='exit;'"<CR>]],
                { silent = true, desc = 'quit terminal' }
            )
        end,
    },
    {
        'goerz/jupytext.vim',
        event = { 'VeryLazy', 'LazyFile' },
        lazy = vim.fn.argc(-1) == 0, -- load jupytext early when opening a file from the cmdline
        init = function()
            vim.g.jupytext_enabled = 1
            -- the jupytext_fmt is not flexible enough to support fetch the format
            -- dynamically for example if you want to use jupytext for both python and
            -- R and given two different formats like py:percent and R:percent (or just
            -- auto:percent). Since it is expected that one will use jupyter notebook
            -- mainly for python I will just set the default format to py:percent.

            -- TODO: write a PR to jupytext.vim to support multiple format.
            vim.g.jupytext_fmt = 'py:percent'
        end,
    },
    {
        'milanglacier/yarepl.nvim',
        event = 'VeryLazy',
        config = function()
            local yarepl = require 'yarepl'
            local aider = require 'yarepl.extensions.aider'

            yarepl.setup {
                metas = { aider = aider.create_aider_meta(), python = false, R = false },
            }
        end,
        init = function()
            ----- Set Aichat Keymap ------
            keymap('n', '<Leader>cs', '<Plug>(REPLStart-aichat)', {
                desc = 'Start an Aichat REPL',
            })
            keymap('n', '<Leader>cf', '<Plug>(REPLFocus-aichat)', {
                desc = 'Focus on Aichat REPL',
            })
            keymap('n', '<Leader>ch', '<Plug>(REPLHide-aichat)', {
                desc = 'Hide Aichat REPL',
            })
            keymap('v', '<Leader>cr', '<Plug>(REPLSendVisual-aichat)', {
                desc = 'Send visual region to Aichat',
            })
            keymap('n', '<Leader>crr', '<Plug>(REPLSendLine-aichat)', {
                desc = 'Send lines to Aichat',
            })
            keymap('n', '<Leader>cr', '<Plug>(REPLSendOperator-aichat)', {
                desc = 'Send Operator to Aichat',
            })
            keymap('n', '<Leader>ce', '<Plug>(REPLExec-aichat)', {
                desc = 'Execute command in aichat',
            })
            keymap('n', '<Leader>cq', '<Plug>(REPLClose-aichat)', {
                desc = 'Quit Aichat',
            })
            keymap('n', '<Leader>cc', '<CMD>REPLCleanup<CR>', {
                desc = 'Clear aichat REPLs.',
            })

            ----- Set Aider Keymap ------
            -- general keymap from yarepl
            keymap('n', '<Leader>as', '<Plug>(REPLStart-aider)', {
                desc = 'Start an aider REPL',
            })
            keymap('n', '<Leader>af', '<Plug>(REPLFocus-aider)', {
                desc = 'Focus on aider REPL',
            })
            keymap('n', '<Leader>ah', '<Plug>(REPLHide-aider)', {
                desc = 'Hide aider REPL',
            })
            keymap('v', '<Leader>ar', '<Plug>(REPLSendVisual-aider)', {
                desc = 'Send visual region to aider',
            })
            keymap('n', '<Leader>arr', '<Plug>(REPLSendLine-aider)', {
                desc = 'Send lines to aider',
            })
            keymap('n', '<Leader>ar', '<Plug>(REPLSendOperator-aider)', {
                desc = 'Send Operator to aider',
            })

            -- special keymap from aider
            keymap('n', '<Leader>ae', '<Plug>(AiderExec)', {
                desc = 'Execute command in aider',
            })
            keymap('n', '<Leader>ay', '<Plug>(AiderSendYes)', {
                desc = 'Send y to aider',
            })
            keymap('n', '<Leader>an', '<Plug>(AiderSendNo)', {
                desc = 'Send n to aider',
            })
            keymap('n', '<Leader>aa', '<Plug>(AiderSendAbort)', {
                desc = 'Send abort to aider',
            })
            keymap('n', '<Leader>aq', '<Plug>(AiderSendExit)', {
                desc = 'Send exit to aider',
            })
            keymap('n', '<Leader>ama', '<Plug>(AiderSendAskMode)', {
                desc = 'Switch aider to ask mode',
            })
            keymap('n', '<Leader>amc', '<Plug>(AiderSendCodeMode)', {
                desc = 'Switch aider to code mode',
            })
            keymap('n', '<Leader>amA', '<Plug>(AiderSendArchMode)', {
                desc = 'Switch aider to architect mode',
            })
            keymap('n', '<Leader>ag', '<cmd>AiderSetPrefix<cr>', {
                desc = 'set aider prefix',
            })
            keymap('n', '<Leader>aG', '<cmd>AiderRemovePrefix<cr>', {
                desc = 'remove aider prefix',
            })
            keymap('n', '<Leader>a<space>', '<cmd>checktime<cr>', {
                desc = 'sync file changes by aider to nvim buffer',
            })

            ----- Set Filetype Specific keymap -----
            local ft_to_repl = {
                r = 'radian',
                R = 'radian',
                rmd = 'radian',
                quarto = 'radian',
                markdown = 'radian',
                python = 'ipython',
                sh = 'bash',
            }

            autocmd('FileType', {
                pattern = { 'quarto', 'markdown', 'rmd', 'python', 'sh', 'REPL', 'r' },
                group = my_augroup,
                desc = 'set up REPL keymap',
                callback = function()
                    local repl = ft_to_repl[vim.bo.filetype]
                    repl = repl and ('-' .. repl) or ''

                    bufmap(0, 'n', '<LocalLeader>rs', string.format('<Plug>(REPLStart%s)', repl), {
                        desc = 'Start an REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rf', '<Plug>(REPLFocus)', {
                        desc = 'Focus on REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rv', '<CMD>FF repl_show<CR>', {
                        desc = 'View REPLs in telescope',
                    })
                    bufmap(0, 'n', '<LocalLeader>rh', '<Plug>(REPLHide)', {
                        desc = 'Hide REPL',
                    })
                    bufmap(0, 'v', '<LocalLeader>s', '<Plug>(REPLSendVisual)', {
                        desc = 'Send visual region to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>ss', '<Plug>(REPLSendLine)', {
                        desc = 'Send line to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>s', '<Plug>(REPLSendOperator)', {
                        desc = 'Send current line to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>re', '<Plug>(REPLExec)', {
                        desc = 'Execute command in REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rq', '<Plug>(REPLClose)', {
                        desc = 'Quit REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rc', '<CMD>REPLCleanup<CR>', {
                        desc = 'Clear REPLs.',
                    })
                    bufmap(0, 'n', '<LocalLeader>rS', '<CMD>REPLSwap<CR>', {
                        desc = 'Swap REPLs.',
                    })
                    bufmap(0, 'n', '<LocalLeader>r?', '<Plug>(REPLStart)', {
                        desc = 'Start an REPL from available REPL metas',
                    })
                    bufmap(0, 'n', '<LocalLeader>ra', '<CMD>REPLAttachBufferToREPL<CR>', {
                        desc = 'Attach current buffer to a REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rd', '<CMD>REPLDetachBufferToREPL<CR>', {
                        desc = 'Detach current buffer to any REPL',
                    })

                    local function send_a_code_chunk()
                        local leader = vim.g.mapleader
                        local localleader = vim.g.maplocalleader
                        -- NOTE: in an expr mapping, <Leader> and <LocalLeader>
                        -- cannot be translated. You must use their literal value
                        -- in the returned string.

                        if vim.bo.filetype == 'r' or vim.bo.filetype == 'python' then
                            return localleader .. 'si' .. leader .. 'c'
                        elseif
                            vim.bo.filetype == 'rmd'
                            or vim.bo.filetype == 'quarto'
                            or vim.bo.filetype == 'markdown'
                        then
                            return localleader .. 'sic'
                        end
                    end

                    bufmap(0, 'n', '<localleader>sc', '', {
                        desc = 'send a code chunk',
                        callback = send_a_code_chunk,
                        expr = true,
                    })
                end,
            })
        end,
    },
    {
        'lewis6991/gitsigns.nvim',
        event = 'LazyFile',
        init = function()
            keymap('n', '<Leader>gp', '<cmd>Gitsigns preview_hunk<CR>', { desc = 'preview hunk' })
            keymap(
                'n',
                '<Leader>gv',
                '<cmd>Gitsigns preview_hunk_inline<CR>',
                { desc = 'preview hunk as virtual text' }
            )
            keymap('n', '<Leader>gB', '<cmd>Gitsigns blame<CR>', {})
            keymap('n', '<Leader>gb', '<cmd>Gitsigns blame_line<CR>', {})
            keymap('n', '<Leader>ga', '<cmd>Gitsigns<CR>', {})
            keymap('n', '<Leader>gr', '<cmd>Gitsigns reset_hunk<CR>', {})
            keymap('n', '<Leader>gs', '<cmd>Gitsigns stage_hunk<CR>', { desc = 'stage or unstage hunk' })
            keymap('v', '<Leader>gs', ':<C-U>Gitsigns stage_hunk<CR>', {})
            keymap('n', '<Leader>gq', '<cmd>Gitsigns setqflist<CR>', {})
            keymap('n', ']h', '', {
                desc = 'git next hunk',
                callback = function()
                    if vim.wo.diff then
                        vim.cmd 'normal! ]c'
                    else
                        require('gitsigns').nav_hunk 'next'
                    end
                end,
            })
            keymap('n', '[h', '', {
                desc = 'git prv hunk',
                callback = function()
                    if vim.wo.diff then
                        vim.cmd 'normal! [c'
                    else
                        require('gitsigns').nav_hunk 'prev'
                    end
                end,
            })

            -- text objects
            keymap('v', 'ih', '<esc><cmd>Gitsigns select_hunk<CR>', {})
            keymap('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>', {})
        end,
        config = function()
            require('gitsigns').setup { update_debounce = 200 }
        end,
    },
    {
        'sindrets/diffview.nvim',
        -- I don't use this plugin very often. I've thought about removing it,
        -- but it's still pretty useful, especially for showing side-by-side
        -- diffs in two panels. So, I decided to keep the plugin and its
        -- commands around, but I didn't set up any keymaps for it. This way,
        -- it's there when I need it, but it doesn't take up space in my
        -- regular key bindings.
        cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    },
    {
        'MagicDuck/grug-far.nvim',
        init = function()
            local function grugfar(mode, wincmd, current_word, current_file)
                return function()
                    local caller
                    if mode == 'n' then
                        caller = 'grug_far'
                    else
                        -- send control-u before calling the command
                        -- This is required for visual mode
                        vim.api.nvim_feedkeys('\27', 'nx', false)
                        caller = 'with_visual_selection'
                    end

                    require('grug-far')[caller] {
                        windowCreationCommand = wincmd,
                        prefills = {
                            search = (mode == 'n' and current_word) and vim.fn.expand '<cword>' or nil,
                            paths = current_file and vim.fn.expand '%' or nil,
                        },
                    }
                end
            end

            for _, mode in ipairs { 'n', 'v' } do
                keymap(mode, '<Leader>/', '', {
                    callback = grugfar(mode, 'tabnew', nil, nil),
                    desc = 'Search and Replace',
                })
                keymap(mode, '<Leader>ss', '', {
                    callback = grugfar(mode, 'split', true, nil),
                    desc = 'hsplit: S/R selected words',
                })
                keymap(mode, '<Leader>sv', '', {
                    callback = grugfar(mode, 'vsplit', true, nil),
                    desc = 'vsplit: S/R selected words',
                })
                keymap(mode, '<Leader>st', '', {
                    callback = grugfar(mode, 'tabnew', true, nil),
                    desc = 'tabnew: S/R of selected words',
                })
                keymap(mode, '<Leader>sf', '', {
                    callback = grugfar(mode, 'vsplit', true, true),
                    desc = 'vsplit: S/R selected words in current file',
                })
            end
        end,
        config = function()
            require('grug-far').setup { startInInsertMode = false }
        end,
    },
    {
        'ludovicchabant/vim-gutentags',
        init = function()
            vim.g.gutentags_add_ctrlp_root_markers = 0
            vim.g.gutentags_ctags_exclude = { '.*', '**/.*' }
            vim.g.gutentags_generate_on_new = 0
            vim.g.gutentags_generate_on_missing = 0
            vim.g.gutentags_ctags_tagfile = '.tags'
            vim.g.gutentags_ctags_extra_args = { [[--fields=*]] }

            vim.filetype.add {
                pattern = {
                    ['%.tags'] = 'tags',
                },
            }
        end,
        event = 'VeryLazy',
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'rmd', 'quarto' },
        config = function()
            require('render-markdown').setup {
                file_types = { 'markdown', 'rmd', 'quarto' },
                code = {
                    sign = false,
                },
                heading = {
                    sign = false,
                    icons = { '󰬺 ', '󰬻 ', '󰬼 ', '󰬽 ', '󰬾 ', '󰬿 ' },
                },
            }
        end,
    },
}
