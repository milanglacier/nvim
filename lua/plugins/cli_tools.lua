local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufmap = vim.api.nvim_buf_set_keymap
local command = vim.api.nvim_create_user_command

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
        cmd = { 'REPLStart' },
        config = function()
            require('yarepl').setup {
                wincmd = function(bufnr, name)
                    if vim.g.REPL_use_floatwin == 1 then
                        vim.api.nvim_open_win(bufnr, true, {
                            relative = 'editor',
                            row = math.floor(vim.o.lines * 0.25),
                            col = math.floor(vim.o.columns * 0.25),
                            width = math.floor(vim.o.columns * 0.5),
                            height = math.floor(vim.o.lines * 0.5),
                            style = 'minimal',
                            title = name,
                            border = 'rounded',
                            title_pos = 'center',
                        })
                    else
                        vim.cmd [[belowright 15 split]]
                        vim.api.nvim_set_current_buf(bufnr)
                    end
                end,
            }

            require('telescope').load_extension 'REPLShow'
        end,
        init = function()
            vim.g.REPL_use_floatwin = 0

            local function run_cmd_with_count(cmd)
                return function()
                    vim.cmd(string.format('%d%s', vim.v.count, cmd))
                end
            end

            local function partial_cmd_with_count_expr(cmd)
                return function()
                    -- <C-U> is equivalent to \21, we want to clear the range before
                    -- next input to ensure the count is recognized correctly.
                    return ':\21' .. vim.v.count .. cmd
                end
            end

            command('REPLToggleFloatWin', function()
                vim.g.REPL_use_floatwin = vim.g.REPL_use_floatwin == 1 and 0 or 1
            end, {})

            keymap('n', '<Leader>tR', '<CMD>REPLToggleFloatWin<CR>', {
                desc = 'Toggle float win for REPL',
            })

            keymap('n', '<Leader>cs', '', {
                callback = run_cmd_with_count 'REPLStart aichat',
                desc = 'Start an Aichat REPL',
            })
            keymap('n', '<Leader>cf', '', {
                callback = run_cmd_with_count 'REPLFocus aichat',
                desc = 'Focus on Aichat REPL',
            })
            keymap('n', '<Leader>ch', '', {
                callback = run_cmd_with_count 'REPLHide aichat',
                desc = 'Hide Aichat REPL',
            })
            keymap('v', '<Leader>cr', '', {
                callback = run_cmd_with_count 'REPLSendVisual aichat',
                desc = 'Send visual region to Aichat',
            })
            keymap('n', '<Leader>crr', '', {
                callback = run_cmd_with_count 'REPLSendLine aichat',
                desc = 'Send lines to Aichat',
            })
            keymap('n', '<Leader>cr', '', {
                callback = run_cmd_with_count 'REPLSendOperator aichat',
                desc = 'Send current line to Aichat',
            })
            keymap('n', '<Leader>ce', '', {
                callback = partial_cmd_with_count_expr 'REPLExec $aichat ',
                desc = 'Execute command in aichat',
                expr = true,
            })
            keymap('n', '<Leader>cq', '', {
                callback = run_cmd_with_count 'REPLClose aichat',
                desc = 'Quit Aichat',
            })
            keymap('n', '<Leader>cc', '<CMD>REPLCleanup<CR>', {
                desc = 'Clear aichat REPLs.',
            })

            local ft_to_repl = {
                r = 'radian',
                R = 'radian',
                rmd = 'radian',
                quarto = 'radian',
                markdown = 'radian',
                ['markdown.pandoc'] = 'radian',
                python = 'ipython',
                sh = 'bash',
                REPL = '',
            }

            autocmd('FileType', {
                pattern = { 'quarto', 'markdown', 'markdown.pandoc', 'rmd', 'python', 'sh', 'REPL', 'r' },
                group = my_augroup,
                desc = 'set up REPL keymap',
                callback = function()
                    local repl = ft_to_repl[vim.bo.filetype]
                    bufmap(0, 'n', '<LocalLeader>rs', '', {
                        callback = run_cmd_with_count('REPLStart ' .. repl),
                        desc = 'Start an REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rf', '', {
                        callback = run_cmd_with_count 'REPLFocus',
                        desc = 'Focus on REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rv', '<CMD>Telescope REPLShow<CR>', {
                        desc = 'View REPLs in telescope',
                    })
                    bufmap(0, 'n', '<LocalLeader>rh', '', {
                        callback = run_cmd_with_count 'REPLHide',
                        desc = 'Hide REPL',
                    })
                    bufmap(0, 'v', '<LocalLeader>s', '', {
                        callback = run_cmd_with_count 'REPLSendVisual',
                        desc = 'Send visual region to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>ss', '', {
                        callback = run_cmd_with_count 'REPLSendLine',
                        desc = 'Send line to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>s', '', {
                        callback = run_cmd_with_count 'REPLSendOperator',
                        desc = 'Send current line to REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>re', '', {
                        callback = partial_cmd_with_count_expr 'REPLExec ',
                        desc = 'Execute command in REPL',
                        expr = true,
                    })
                    bufmap(0, 'n', '<LocalLeader>rq', '', {
                        callback = run_cmd_with_count 'REPLClose',
                        desc = 'Quit REPL',
                    })
                    bufmap(0, 'n', '<LocalLeader>rc', '<CMD>REPLCleanup<CR>', {
                        desc = 'Clear REPLs.',
                    })
                    bufmap(0, 'n', '<LocalLeader>rS', '<CMD>REPLSwap<CR>', {
                        desc = 'Swap REPLs.',
                    })
                    bufmap(0, 'n', '<LocalLeader>r?', '', {
                        callback = run_cmd_with_count 'REPLStart',
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
        cmd = 'Gitsigns',
        init = function()
            keymap('n', '<Leader>gp', '<cmd>Gitsigns preview_hunk<CR>', { noremap = true })
            keymap('n', '<Leader>ga', '<cmd>Gitsigns<CR>', { noremap = true })
            keymap('n', '<Leader>gr', '<cmd>Gitsigns reset_hunk<CR>', { noremap = true })
            keymap('n', '<Leader>gs', '<cmd>Gitsigns stage_hunk<CR>', { noremap = true })
            keymap('n', '<Leader>gq', '<cmd>Gitsigns setqflist<CR>', { noremap = true })
            keymap('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { noremap = true })
            keymap('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { noremap = true })
        end,
        config = function()
            require('gitsigns').setup {
                current_line_blame = true,
                current_line_blame_formatter = '<author>, <author_time:%R> - <summary> - <abbrev_sha>',
            }
        end,
    },
    {
        'NeogitOrg/neogit',
        cmd = 'Neogit',
        init = function()
            keymap('n', '<Leader>gg', '<cmd>Neogit<CR>', { noremap = true, desc = 'Neogit' })
        end,
        config = function()
            require('neogit').setup { console_timeout = 4000 }
        end,
    },
    {
        'sindrets/diffview.nvim',
        cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
        init = function()
            keymap('n', '<Leader>gd', '<cmd>DiffviewOpen<CR>', { noremap = true })
            keymap('n', '<Leader>gf', '<cmd>DiffviewFileHistory<CR>', { noremap = true })
        end,
    },
    {
        'nvim-pack/nvim-spectre',
        init = function()
            keymap(
                'n',
                '<Leader>fR',
                "<cmd>lua require('spectre').open()<CR>",
                { noremap = true, desc = 'rg at side panel' }
            )
            keymap(
                'v',
                '<Leader>fR',
                ":<C-U>lua require('spectre').open_visual()<CR>",
                { noremap = true, desc = 'rg at side panel' }
            )
        end,
    },
    {
        'iamcco/markdown-preview.nvim',
        build = 'cd app && npm install',
        ft = { 'markdown.pandoc', 'markdown', 'rmd', 'quarto' },
        init = function()
            vim.g.mkdp_filetypes = { 'markdown.pandoc', 'markdown', 'rmd', 'quarto' }

            keymap('n', '<Leader>mmp', '<cmd>MarkdownPreview<cr>', { noremap = true, desc = 'Misc Markdown Preview' })
            keymap(
                'n',
                '<Leader>mmq',
                '<cmd>MarkdownPreviewStop<cr>',
                { noremap = true, desc = 'Misc Markdown Preview Stop' }
            )
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
    { 'nvim-orgmode/orgmode' },
    { 'lervag/vimtex' },
    { 'jmbuhr/otter.nvim' },
    {
        'Exafunction/codeium.nvim',
        init = function()
            CODEIUM_IS_ENABLED = true

            keymap('n', '<Leader>tg', '', {
                callback = function()
                    local cmp = require 'cmp'
                    local sources = vim.deepcopy(require('conf.cmp').sources)

                    if CODEIUM_IS_ENABLED then
                        for _, source in pairs(sources) do
                            table.remove(source[1], 1)
                        end

                        require('cmp').setup {
                            sources = cmp.setup {
                                sources = cmp.config.sources(unpack(sources.global)),
                            },
                        }
                        cmp.setup.filetype('quarto', {
                            sources = cmp.config.sources(unpack(sources.quarto)),
                        })

                        cmp.setup.filetype({ 'r', 'rmd' }, {
                            sources = cmp.config.sources(unpack(sources.r_rmd)),
                        })

                        CODEIUM_IS_ENABLED = false
                        vim.notify 'codeium is disabled'
                    else
                        require('cmp').setup {
                            sources = cmp.setup {
                                sources = cmp.config.sources(unpack(sources.global)),
                            },
                        }
                        cmp.setup.filetype('quarto', {
                            sources = cmp.config.sources(unpack(sources.quarto)),
                        })

                        cmp.setup.filetype({ 'r', 'rmd' }, {
                            sources = cmp.config.sources(unpack(sources.r_rmd)),
                        })

                        CODEIUM_IS_ENABLED = true
                        vim.notify 'codeium is enabled'
                    end
                end,
                desc = 'toggle codeium',
            })
        end,
        event = 'InsertEnter',
        config = function()
            require('codeium').setup {}
        end,
    },
}
