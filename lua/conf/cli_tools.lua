local M = {}
M.load = {}

local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufcmd = vim.api.nvim_buf_create_user_command
local bufmap = vim.api.nvim_buf_set_keymap
local command = vim.api.nvim_create_user_command

local lazy = require 'lazy'

M.load.gitsigns = function()
    require('gitsigns').setup {
        current_line_blame = true,
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary> - <abbrev_sha>',
    }

    keymap('n', '<Leader>gp', '<cmd>Gitsigns preview_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>ga', '<cmd>Gitsigns<CR>', { noremap = true })
    keymap('n', '<Leader>gr', '<cmd>Gitsigns reset_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>gs', '<cmd>Gitsigns stage_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>gq', '<cmd>Gitsigns setqflist<CR>', { noremap = true })
    keymap('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { noremap = true })
    keymap('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { noremap = true })
end

M.load.neogit = function()
    require('neogit').setup {}
    keymap('n', '<Leader>gg', '<cmd>Neogit<CR>', { noremap = true, desc = 'Neogit' })
end

M.load.diffview = function()
    keymap('n', '<Leader>gd', '<cmd>DiffviewOpen<CR>', { noremap = true })
    keymap('n', '<Leader>gf', '<cmd>DiffviewFileHistory<CR>', { noremap = true })
end

M.load.spectre = function()
    keymap('n', '<Leader>fR', "<cmd>lua require('spectre').open()<CR>", { noremap = true, desc = 'rg at side panel' })
    keymap(
        'v',
        '<Leader>fR',
        ":<C-U>lua require('spectre').open_visual()<CR>",
        { noremap = true, desc = 'rg at side panel' }
    )
end

M.load.mkdp = function()
    vim.g.mkdp_filetypes = { 'markdown.pandoc', 'markdown', 'rmd', 'quarto' }

    keymap('n', '<Leader>mmp', '<cmd>MarkdownPreview<cr>', { noremap = true, desc = 'Misc Markdown Preview' })
    keymap('n', '<Leader>mmq', '<cmd>MarkdownPreviewStop<cr>', { noremap = true, desc = 'Misc Markdown Preview Stop' })

    lazy.load { plugins = { 'markdown-preview.nvim' } }
end

M.load.toggleterm = function()
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
    keymap('n', '<Leader>t0', '<cmd>ToggleTermToggleAll<CR>', { desc = 'Toggle display all terminals' })
    keymap('n', '<Leader>t1', '<cmd>1ToggleTerm<CR>', { desc = 'Toggle terminal with id 1' })
    keymap('n', '<Leader>t2', '<cmd>2ToggleTerm<CR>', { desc = 'Toggle terminal with id 2' })
    keymap('n', '<Leader>t3', '<cmd>3ToggleTerm<CR>', { desc = 'Toggle terminal with id 3' })
    keymap('n', '<Leader>t4', '<cmd>4ToggleTerm<CR>', { desc = 'Toggle terminal with id 4' })
    keymap(
        'n',
        '<Leader>t!',
        [[<cmd>execute v:count . "TermExec cmd='exit;'"<CR>]],
        { silent = true, desc = 'quit terminal' }
    )

    autocmd('FileType', {
        desc = 'set command for rendering rmarkdown',
        pattern = 'rmd',
        group = my_augroup,
        callback = function()
            bufcmd(0, 'RenderRmd', function(options)
                local winid = vim.api.nvim_get_current_win()
                ---@diagnostic disable-next-line: missing-parameter
                local current_file = vim.fn.expand '%:.' -- relative path to current wd
                current_file = vim.fn.shellescape(current_file)

                local cmd = string.format([[R --quiet -e "rmarkdown::render(%s)"]], current_file)
                local term_id = options.args ~= '' and tonumber(options.args) or nil

                ---@diagnostic disable-next-line: missing-parameter
                require('toggleterm').exec(cmd, term_id)
                vim.cmd.normal { 'G', bang = true }
                vim.api.nvim_set_current_win(winid)
            end, {
                nargs = '?', -- 0 or 1 arg
            })
        end,
    })

    autocmd('FileType', {
        desc = 'set command for rendering quarto',
        pattern = 'quarto',
        group = my_augroup,
        callback = function()
            bufcmd(0, 'RenderQuarto', function(options)
                local winid = vim.api.nvim_get_current_win()
                ---@diagnostic disable-next-line: missing-parameter
                local current_file = vim.fn.expand '%:.' -- relative path to current wd
                current_file = vim.fn.shellescape(current_file)

                local cmd = string.format([[quarto render %s]], current_file)
                local term_id = options.args ~= '' and tonumber(options.args) or nil

                ---@diagnostic disable-next-line: missing-parameter
                require('toggleterm').exec(cmd, term_id)
                vim.cmd.normal { 'G', bang = true }
                vim.api.nvim_set_current_win(winid)
            end, {
                nargs = '?', -- 0 or 1 arg
            })

            bufcmd(0, 'PreviewQuarto', function(options)
                local winid = vim.api.nvim_get_current_win()
                ---@diagnostic disable-next-line: missing-parameter
                local current_file = vim.fn.expand '%:.' -- relative path to current wd
                current_file = vim.fn.shellescape(current_file)

                local cmd = string.format([[quarto preview %s]], current_file)
                local term_id = options.args ~= '' and tonumber(options.args) or nil

                ---@diagnostic disable-next-line: missing-parameter
                require('toggleterm').exec(cmd, term_id)
                vim.cmd.normal { 'G', bang = true }
                vim.api.nvim_set_current_win(winid)
            end, {
                nargs = '?', -- 0 or 1 arg
            })
        end,
    })
end

M.load.gutentags = function()
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

    lazy.load { plugins = { 'vim-gutentags' } }
end

M.load.copilot = function()
    autocmd('InsertEnter', {
        group = my_augroup,
        once = true,
        desc = 'load copilot',
        callback = function()
            local copilot_enabled = false
            local copilot_is_setup = false

            local copilot_config = {
                panel = {
                    enabled = false,
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 150,
                    keymap = {
                        accept = '<M-Y>',
                        next = '<M-]>',
                        prev = '<M-[>',
                        dismiss = '<M-q>',
                    },
                },
            }

            keymap('n', '<Leader>tg', '', {
                noremap = true,
                callback = function()
                    if not copilot_is_setup then
                        require('copilot').setup(copilot_config)
                        copilot_is_setup = true
                        copilot_enabled = true
                        vim.notify 'Copilot enable'
                        return
                    end

                    copilot_enabled = not copilot_enabled
                    copilot_subcmd = copilot_enabled and 'enable' or 'disable'

                    vim.cmd(string.format('Copilot %s', copilot_subcmd))
                    vim.notify(string.format('Copilot %s', copilot_subcmd))
                end,
                desc = 'toggle copilot',
            })

            keymap('i', '<M-y>', '', {
                noremap = true,
                callback = require('copilot.suggestion').accept_line,
                desc = '[copilot] accept line',
            })
        end,
    })
end

M.load.jupytext = function()
    vim.g.jupytext_enabled = 1
    -- the jupytext_fmt is not flexible enough to support fetch the format
    -- dynamically for example if you want to use jupytext for both python and
    -- R and given two different formats like py:percent and R:percent (or just
    -- auto:percent). Since it is expected that one will use jupyter notebook
    -- mainly for python I will just set the default format to py:percent.

    -- TODO: write a PR to jupytext.vim to support multiple format.
    vim.g.jupytext_fmt = 'py:percent'

    lazy.load { plugins = { 'jupytext.vim' } }
end

M.load.mason = function()
    require('mason').setup {}
end

M.load.REPL = function()
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

    vim.g.REPL_use_floatwin = 0

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
                elseif vim.bo.filetype == 'rmd' or vim.bo.filetype == 'quarto' or vim.bo.filetype == 'markdown' then
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
end

M.load.diffview()
M.load.gitsigns()
M.load.mkdp()
M.load.neogit()
M.load.spectre()
M.load.toggleterm()
M.load.gutentags()
M.load.copilot()
M.load.jupytext()
M.load.mason()
M.load.REPL()

return M
