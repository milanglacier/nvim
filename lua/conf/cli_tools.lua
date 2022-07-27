local M = {}
M.load = {}

local keymap = vim.api.nvim_set_keymap

M.load.gitsigns = function()
    vim.cmd.packadd { 'gitsigns.nvim', bang = true }

    require('gitsigns').setup {
        current_line_blame = true,
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
    }

    keymap('n', '<Leader>gp', '<cmd>Gitsigns preview_hunk<CR>', { noremap = true })
    keymap('n', '<Leader>gq', '<cmd>Gitsigns setqflist<CR>', { noremap = true })
end

M.load.neogit = function()
    vim.cmd.packadd { 'neogit', bang = true }
end

M.load.diffview = function()
    vim.cmd.packadd { 'diffview.nvim', bang = true }
end

M.load.spectre = function()
    vim.cmd.packadd { 'nvim-spectre', bang = true }

    require('spectre').setup()

    keymap('n', '<Leader>fR', "<cmd>lua require('spectre').open()<CR>", { noremap = true, desc = 'rg at side panel' })
    keymap(
        'v',
        '<Leader>fR',
        ":<C-U>lua require('spectre').open_visual()<CR>",
        { noremap = true, desc = 'rg at side panel' }
    )
end

M.load.mkdp = function()
    vim.cmd.packadd { 'markdown-preview.nvim', bang = true }

    vim.g.mkdp_filetypes = { 'markdown.pandoc', 'markdown', 'rmd' }

    keymap('n', '<LocalLeader>mp', ':MarkdownPreview<cr>', { noremap = true, silent = true })
    keymap('n', '<LocalLeader>mq', ':MarkdownPreviewStop<cr>', { noremap = true, silent = true })
end

M.load.iron = function()
    vim.cmd.packadd { 'iron.nvim', bang = true }

    local iron = require 'iron.core'
    local mypath = require 'bin_path'

    local radian = require('iron.fts.r').radian
    local ipython = require('iron.fts.python').ipython
    radian.command = { mypath.radian }
    ipython.command = { mypath.ipython }

    iron.setup {
        config = {
            scratch_repl = true,
            repl_definition = {
                r = radian,
                rmd = radian,
                python = ipython,
            },
            repl_open_cmd = 'belowright 15 split',
            buflisted = true,
        },
        keymaps = {
            send_motion = '<LocalLeader>s',
            visual_send = '<LocalLeader>ss',
            send_file = '<LocalLeader>sf',
            send_line = '<LocalLeader>ss',
            send_mark = '<LocalLeader>sm',
            cr = '<LocalLeader>s<cr>',
            interrupt = '<LocalLeader>ri',
            exit = '<LocalLeader>rq',
            clear = '<LocalLeader>rc',
        },
    }

    keymap('n', '<localleader>rs', '<cmd>IronRepl<CR>', {})
    keymap('n', '<localleader>rr', '<cmd>IronRestart<CR>', {})

    keymap('n', '<localleader>sc', '', {
        desc = 'iron send a code chunk',
        callback = function()
            local local_leader = vim.g.maplocalleader
            local leader = vim.g.mapleader

            if vim.bo.filetype == 'r' or vim.bo.filetype == 'python' then
                return local_leader .. 'si' .. leader .. 'c'
            elseif vim.bo.filetype == 'rmd' then
                return local_leader .. 'sic'
                -- Note: in an expression mapping, <LocalLeader>
                -- and <Leader> cannot be automatically mapped
                -- to the corresponding keys, you have to do the mapping manually
            end
        end,
        expr = true,
    })
end

M.load.toggleterm = function()
    vim.cmd.packadd { 'toggleterm.nvim', bang = true }

    require('toggleterm').setup {
        -- size can be a number or function which is passed the current terminal
        size = function(term)
            if term.direction == 'horizontal' then
                return 15
            elseif term.direction == 'vertical' then
                return vim.o.columns * 0.30
            end
        end,
        open_mapping = [[<Leader>tw]],
        shade_terminals = false,
        start_in_insert = false,
        insert_mappings = false,
        terminal_mappings = false,
        persist_size = true,
        direction = 'horizontal',
        close_on_exit = true,
    }
    keymap('n', '<Leader>ta', '<cmd>ToggleTermToggleAll<CR>', { silent = true })
    keymap('n', '<Leader>t2', '<cmd>2ToggleTerm<CR>', { silent = true })
    keymap('n', '<Leader>t3', '<cmd>3ToggleTerm<CR>', { silent = true })
    keymap('n', '<Leader>t4', '<cmd>4ToggleTerm<CR>', { silent = true })
    keymap('n', '<Leader>te', [[<cmd>execute v:count . "TermExec cmd='exit;'"<CR>]], { silent = true })

    local autocmd = vim.api.nvim_create_autocmd
    local my_augroup = require('conf.builtin_extend').my_augroup

    autocmd('FileType', {
        desc = 'set command for rendering rmarkdown',
        pattern = 'rmd',
        group = my_augroup,
        callback = function()
            local bufid = vim.api.nvim_get_current_buf()
            local bufcmd = vim.api.nvim_buf_create_user_command

            bufcmd(0, 'RenderRmd', function(options)
                ---@diagnostic disable-next-line: missing-parameter
                local current_file = vim.fn.expand '%:.' -- relative path to current wd
                current_file = vim.fn.shellescape(current_file)

                local cmd = string.format([[R --quiet -e "rmarkdown::render(%s)"]], current_file)
                local term_id = options.args ~= '' and tonumber(options.args) or nil

                ---@diagnostic disable-next-line: missing-parameter
                require('toggleterm').exec(cmd, term_id)

                vim.api.nvim_set_current_buf(bufid)
            end, {
                nargs = '?', -- 0 or 1 arg
            })
        end,
    })
end

M.load.pandoc = function()
    vim.cmd.packadd { 'vim-pandoc-syntax', bang = true }
    vim.cmd.packadd { 'vim-rmarkdown', bang = true }

    vim.filetype.add {
        extension = {
            md = 'markdown.pandoc',
        },
    }

    vim.g.r_indent_align_args = 0
    vim.g.r_indent_ess_comments = 0
    vim.g.r_indent_ess_compatible = 0

    -- vim.g['pandoc#syntax#conceal#blacklist'] = {'subscript', 'superscript', 'atx'}
    vim.g['pandoc#syntax#codeblocks#embeds#langs'] = { 'python', 'R=r', 'r', 'bash=sh', 'json' }
end

M.load.gutentags = function()
    vim.cmd.packadd { 'vim-gutentags', bang = true }

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
end

M.load.diffview()
M.load.gitsigns()
M.load.iron()
M.load.mkdp()
M.load.neogit()
M.load.spectre()
M.load.toggleterm()
M.load.pandoc()
M.load.gutentags()

return M
