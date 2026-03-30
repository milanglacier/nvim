local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufmap = vim.api.nvim_buf_set_keymap

return {
    -- an installer for a bunch of CLI tools (e.g. LSP, linters)
    {
        'mason-org/mason.nvim',
        cmd = { 'Mason', 'MasonInstall', 'MasonUpdate', 'MasonUninstall' },
        config = function()
            require('mason').setup()
        end,
    },
    {
        -- FIXME:
        -- 1. We are using our own fork instead of the original upstream
        -- (goerz/jupytext.nvim) because our PRs are still awaiting upstream
        -- approval. Until those are merged, we will continue using our fork. A
        -- GitHub Action is configured to perform a daily fast-forward merge
        -- with the upstream repository. This ensures that our fork remains
        -- consistently up to date.
        'milanglacier/jupytext.nvim',
        event = { 'VeryLazy', 'LazyFile' },
        lazy = vim.fn.argc(-1) == 0, -- load jupytext early when opening a file from the cmdline
        branch = 'dev',
        config = function()
            require('jupytext').setup {
                format = 'py:percent',
                -- prevent jupytext.nvim create too many autocmds in non-ipynb
                -- file which is too intrusive
                autosync = false,
            }
        end,
    },
    {
        'milanglacier/yarepl.nvim',
        event = 'VeryLazy',
        lazy = vim.fn.argc(-1) == 0,
        config = function()
            local yarepl = require 'yarepl'
            local aider = require 'yarepl.extensions.aider'
            local codex = require 'yarepl.extensions.codex'

            -- Set the $EDITOR env var to use `nvr` (neovim-remote). Thivariables
            -- ensures that external commands, such as Codex's <C-g> shortcut,
            -- open buffers back into the current Neovim instance instead of
            -- spawning a nested one.
            if vim.fn.executable 'nvr' == 1 then
                vim.env.EDITOR = 'nvr -cc tabnew --remote-wait'
            end

            yarepl.setup {
                source_command_hint = { enabled = true },
                metas = {
                    aider = aider.create_aider_meta(),
                    codex = codex.create_codex_meta(),
                    python = false,
                    R = false,
                    radian = { cmd = 'R' },
                    shell = {
                        cmd = vim.o.shell,
                        wincmd = function(bufnr, name)
                            local winid = vim.api.nvim_open_win(bufnr, true, {
                                -- Position the terminal window at the
                                -- bottom-right corner, relative to the
                                -- statusline.
                                relative = 'laststatus',
                                row = 0,
                                col = math.floor(vim.o.columns * 0.75),
                                width = math.floor(vim.o.columns * 0.5),
                                height = math.floor(vim.o.lines * 0.4),
                                style = 'minimal',
                                title = name,
                                border = 'rounded',
                                title_pos = 'center',
                            })
                            vim.wo[winid].winbar = '%t'
                        end,
                        formatter = 'bracketed_pasting',
                    },
                },
            }

            require('yarepl.extensions.code_cell').register_text_objects {
                {
                    key = 'c',
                    start_pattern = '```.+',
                    end_pattern = '^```$',
                    ft = { 'rmd', 'quarto', 'markdown' },
                    desc = 'markdown code cells',
                },
                {
                    key = '<Leader>c',
                    start_pattern = '^# ?%%%%.*',
                    end_pattern = '^# ?%%%%.*',
                    ft = { 'r', 'python' },
                    desc = 'r/python code cells',
                },
                {
                    key = 'm',
                    start_pattern = '# COMMAND ---',
                    end_pattern = '# COMMAND ---',
                    ft = { 'r', 'python' },
                    desc = 'databricks code cells',
                },
                {
                    key = 'm',
                    start_pattern = '-- COMMAND ---',
                    end_pattern = '-- COMMAND ---',
                    ft = { 'sql' },
                    desc = 'databricks code cells',
                },
            }
        end,
        init = function()
            ----- Set Aichat Keymap ------
            keymap('n', '<Leader>cs', '<Plug>(Yarepl-start-aichat)', {
                desc = 'Start an Aichat REPL',
            })
            keymap('n', '<Leader>cf', '<Plug>(Yarepl-focus-aichat)', {
                desc = 'Focus on Aichat REPL',
            })
            keymap('n', '<Leader>ch', '<Plug>(Yarepl-hide-aichat)', {
                desc = 'Hide Aichat REPL',
            })
            keymap('v', '<Leader>cr', '<Plug>(Yarepl-source-visual-aichat)', {
                desc = 'Source visual region to Aichat',
            })
            keymap('v', '<Leader>cR', '<Plug>(Yarepl-send-visual-aichat)', {
                desc = 'Send visual region to Aichat',
            })
            keymap('n', '<Leader>crr', '<Plug>(Yarepl-send-line-aichat)', {
                desc = 'Send line to Aichat',
            })
            keymap('n', '<Leader>cr', '<Plug>(Yarepl-source-operator-aichat)', {
                desc = 'Source Operator to Aichat',
            })
            keymap('n', '<Leader>cR', '<Plug>(Yarepl-send-operator-aichat)', {
                desc = 'Send Operator to Aichat',
            })
            keymap('n', '<Leader>ce', '<Plug>(Yarepl-exec-aichat)', {
                desc = 'Execute command in aichat',
            })
            keymap('n', '<Leader>cq', '<Plug>(Yarepl-close-aichat)', {
                desc = 'Quit Aichat',
            })
            keymap('n', '<Leader>cc', '<CMD>Yarepl cleanup<CR>', {
                desc = 'Clear aichat REPLs.',
            })

            ----- Set codex Keymap ------
            keymap('n', '<Leader>zs', '<Plug>(Yarepl-start-codex)', {
                desc = 'Start an codex REPL',
            })
            keymap('n', '<Leader>zf', '<Plug>(Yarepl-focus-codex)', {
                desc = 'Focus on codex REPL',
            })
            keymap('n', '<Leader>zh', '<Plug>(Yarepl-hide-codex)', {
                desc = 'Hide codex REPL',
            })
            keymap('v', '<Leader>zr', '<Plug>(Yarepl-send-visual-codex)', {
                desc = 'Send visual region to codex',
            })
            keymap('n', '<Leader>zrr', '<Plug>(Yarepl-send-line-codex)', {
                desc = 'Send lines to codex',
            })
            keymap('n', '<Leader>zr', '<Plug>(Yarepl-send-operator-codex)', {
                desc = 'Send Operator to codex',
            })
            keymap('n', '<Leader>ze', '<Plug>(yarepl-codex-exec)', {
                desc = 'Execute command in codex',
            })
            keymap('n', '<Leader>zg', '<Plug>(yarepl-codex-send-open-editor)', {
                desc = 'Open Editor in codex',
            })
            keymap('n', '<Leader>z<space>', '<cmd>checktime<cr>', {
                desc = 'sync file changes by codex to nvim buffer',
            })

            ----- Set Aider Keymap ------
            -- general keymap from yarepl
            keymap('n', '<Leader>as', '<Plug>(Yarepl-start-aider)', {
                desc = 'Start an aider REPL',
            })
            keymap('n', '<Leader>af', '<Plug>(Yarepl-focus-aider)', {
                desc = 'Focus on aider REPL',
            })
            keymap('n', '<Leader>ah', '<Plug>(Yarepl-hide-aider)', {
                desc = 'Hide aider REPL',
            })
            keymap('v', '<Leader>ar', '<Plug>(Yarepl-send-visual-aider)', {
                desc = 'Send visual region to aider',
            })
            keymap('n', '<Leader>arr', '<Plug>(Yarepl-send-line-aider)', {
                desc = 'Send lines to aider',
            })
            keymap('n', '<Leader>ar', '<Plug>(Yarepl-send-operator-aider)', {
                desc = 'Send Operator to aider',
            })

            -- special keymap from aider
            keymap('n', '<Leader>ae', '<Plug>(yarepl-aider-exec)', {
                desc = 'Execute command in aider',
            })
            keymap('n', '<Leader>ay', '<Plug>(yarepl-aider-send-yes)', {
                desc = 'Send y to aider',
            })
            keymap('n', '<Leader>an', '<Plug>(yarepl-aider-send-no)', {
                desc = 'Send n to aider',
            })
            keymap('n', '<Leader>aa', '<Plug>(yarepl-aider-send-abort)', {
                desc = 'Send abort to aider',
            })
            keymap('n', '<Leader>aq', '<Plug>(yarepl-aider-send-exit)', {
                desc = 'Send exit to aider',
            })
            keymap('n', '<Leader>ama', '<Plug>(yarepl-aider-send-ask-mode)', {
                desc = 'Switch aider to ask mode',
            })
            keymap('n', '<Leader>amc', '<Plug>(yarepl-aider-send-code-mode)', {
                desc = 'Switch aider to code mode',
            })
            keymap('n', '<Leader>amC', '<Plug>(yarepl-aider-send-context-mode)', {
                desc = 'Switch aider to context mode',
            })
            keymap('n', '<Leader>amA', '<Plug>(yarepl-aider-send-arch-mode)', {
                desc = 'Switch aider to architect mode',
            })
            keymap('n', '<Leader>ag', '<cmd>Yarepl aider set_prefix<cr>', {
                desc = 'set aider prefix',
            })
            keymap('n', '<Leader>aG', '<cmd>Yarepl aider remove_prefix<cr>', {
                desc = 'remove aider prefix',
            })
            keymap('n', '<Leader>a<space>', '<cmd>checktime<cr>', {
                desc = 'sync file changes by aider to nvim buffer',
            })

            ----- Set Shell Keymap ------
            keymap('n', '<Leader>ot', '<Plug>(Yarepl-start-shell)', {
                desc = 'Start or focus a shell',
            })
            keymap('n', '<Leader>t1', '<Plug>(Yarepl-focus-shell)', {
                desc = 'Focus on shell',
            })
            keymap('n', '<Leader>t0', '<Plug>(Yarepl-hide-shell)', {
                desc = 'Hide shell REPL',
            })

            ----- Set Filetype Specific keymap -----
            local ft_to_repl = {
                r = 'radian',
                R = 'radian',
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

                    bufmap(0, 'n', '<LocalLeader>rs', string.format('<Plug>(Yarepl-start%s)', repl), {
                        desc = 'Start an REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rf', string.format('<Plug>(Yarepl-focus%s)', repl), {
                        desc = 'Focus on REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rh', string.format('<Plug>(Yarepl-hide%s)', repl), {
                        desc = 'Hide REPL',
                    })
                    bufmap(0, 'v', '<LocalLeader>s', string.format('<Plug>(Yarepl-source-visual%s)', repl), {
                        desc = 'Source visual region to REPL',
                    })
                    bufmap(0, 'v', '<LocalLeader>S', string.format('<Plug>(Yarepl-send-visual%s)', repl), {
                        desc = 'Send visual region to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>ss', string.format('<Plug>(Yarepl-send-line%s)', repl), {
                        desc = 'Send line to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>s', string.format('<Plug>(Yarepl-source-operator%s)', repl), {
                        desc = 'Source Operator to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>S', string.format('<Plug>(Yarepl-send-operator%s)', repl), {
                        desc = 'Send Operator to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>re', string.format('<Plug>(Yarepl-exec%s)', repl), {
                        desc = 'Execute command in REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rq', string.format('<Plug>(Yarepl-close%s)', repl), {
                        desc = 'Quit REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rc', '<CMD>Yarepl cleanup<CR>', {
                        desc = 'Clear REPLs.',
                    })
                    bufmap(0, 'n', '<LocalLeader>rS', '<CMD>Yarepl swap<CR>', {
                        desc = 'Swap REPLs.',
                    })
                    bufmap(0, 'n', '<LocalLeader>r?', '<Plug>(Yarepl-start)', {
                        desc = 'Start an REPL from available REPL metas',
                    })
                    bufmap(0, 'n', '<LocalLeader>ra', '<CMD>Yarepl attach_buffer<CR>', {
                        desc = 'Attach current buffer to a REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rd', '<CMD>Yarepl detach_buffer<CR>', {
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
                        caller = 'open'
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
            vim.g.gutentags_ctags_extra_args = { [[--fields=*]], [[--languages=all]] }

            vim.filetype.add {
                pattern = {
                    ['%.tags'] = 'tags',
                },
            }
        end,
        event = 'VeryLazy',
    },
}
