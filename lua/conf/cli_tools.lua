local M = {}
M.load = {}

local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufcmd = vim.api.nvim_buf_create_user_command
local bufmap = vim.api.nvim_buf_set_keymap

local lazy = require 'lazy'

M.load.gitsigns = function()
    require('gitsigns').setup {
        current_line_blame = true,
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    }

    keymap('n', '<Leader>gp', '<cmd>Gitsigns preview_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>gr', '<cmd>Gitsigns reset_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>gs', '<cmd>Gitsigns stage_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>gq', '<cmd>Gitsigns setqflist<CR>', { noremap = true })
    keymap('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { noremap = true })
    keymap('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { noremap = true })
end

M.load.neogit = function()
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
    keymap('n', '<Leader>ta', '<cmd>ToggleTermToggleAll<CR>', { silent = true })
    keymap('n', '<Leader>t1', '<cmd>1ToggleTerm<CR>', { silent = true })
    keymap('n', '<Leader>t2', '<cmd>2ToggleTerm<CR>', { silent = true })
    keymap('n', '<Leader>t3', '<cmd>3ToggleTerm<CR>', { silent = true })
    keymap('n', '<Leader>t4', '<cmd>4ToggleTerm<CR>', { silent = true })
    keymap(
        'n',
        '<Leader>te',
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
            require('copilot').setup {
                panel = {
                    enabled = false,
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = false,
                    debounce = 75,
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
                callback = require('copilot.suggestion').toggle_auto_trigger,
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
            vim.cmd(string.format('%d%s', vim.v.count1, cmd))
        end
    end

    require('REPL').setup {}

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
        desc = 'Send motion to Aichat',
    })
    keymap('n', '<Leader>cr', '', {
        callback = function()
            require('REPL').send_motion 'aichat'
        end,
        desc = 'Send current line to Aichat',
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
        rmd = 'radian',
        quarto = 'radian',
        markdown = 'radian',
        ['markdown.pandoc'] = 'radian',
        python = 'ipython',
        sh = 'bash',
    }

    autocmd('FileType', {
        pattern = { 'quarto', 'markdown', 'markdown.pandoc', 'rmd', 'python', 'sh' },
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
                desc = 'Send motion to REPL',
            })
            bufmap(0, 'n', '<LocalLeader>s', '', {
                callback = require('REPL').send_motion,
                desc = 'Send current line to REPL',
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
            bufmap(0, 'n', '<LocalLeader>ra', '', {
                callback = run_cmd_with_count 'REPLStart',
                desc = 'Start an REPL with another meta',
            })
            bufmap(0, 'n', '<localleader>sc', '', {
                desc = 'send a code chunk',
                callback = function()
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
                end,
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
