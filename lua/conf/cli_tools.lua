local M = {}
M.load = {}

local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufcmd = vim.api.nvim_buf_create_user_command
local bufmap = vim.api.nvim_buf_set_keymap

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
    keymap('n', '<Leader>gg', '<cmd>Neogit<CR>', { noremap = true })
end

M.load.diffview = function()
    vim.cmd.packadd { 'diffview.nvim', bang = true }
    keymap('n', '<Leader>gd', '<cmd>DiffviewOpen<CR>', { noremap = true })
    keymap('n', '<Leader>gf', '<cmd>DiffviewFileHistory<CR>', { noremap = true })
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

    keymap('n', '<Leader>mmp', '<cmd>MarkdownPreview<cr>', { noremap = true, desc = 'Misc Markdown Preview' })
    keymap('n', '<Leader>mmq', '<cmd>MarkdownPreviewStop<cr>', { noremap = true, desc = 'Misc Markdown Preview Stop' })
end

M.load.iron = function()
    vim.cmd.packadd { 'iron.nvim', bang = true }

    local iron = require 'iron.core'

    local radian = require('iron.fts.r').radian
    local ipython = require('iron.fts.python').ipython

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
            highlight_last = false,
        },
        keymaps = {
            send_motion = '<LocalLeader>s',
            visual_send = '<LocalLeader>s',
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
    keymap('n', '<localleader>rh', '<cmd>IronHide<CR>', {})
    keymap('n', '<localleader>rf', '<cmd>IronFocus<CR>', {})
    keymap('n', '<localleader>rw', '<cmd>IronWatch file<CR>', {})
    keymap('n', '<localleader>ra', ':IronAttach', {})
    -- iron attach will attach current buffer to a running repl
    -- iron focus will reopen a window for current repl if there's no window for repl
    -- iron watch will send the entire file / mark after writing the buffer

    keymap('n', '<localleader>sc', '', {
        desc = 'send a code chunk',
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

    autocmd('FileType', {
        desc = 'set command for rendering rmarkdown',
        pattern = 'rmd',
        group = my_augroup,
        callback = function()
            local winid = vim.api.nvim_get_current_win()

            bufcmd(0, 'RenderRmd', function(options)
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

M.load.nvimr = function()
    vim.g.R_assign = 0
    vim.g.R_app = 'radian'
    vim.g.R_cmd = 'R'
    vim.g.R_args = {}
    vim.g.R_user_maps_only = 1
    vim.g.R_hl_term = 0
    vim.g.R_esc_term = 0
    vim.g.R_buffer_opts = 'buflisted' -- nvimr prevents repl window to be automatically resized, reenable it
    vim.g.R_objbr_place = 'console,right' -- show object browser at the right of the console
    vim.g.R_nvim_wd = 1

    local function opts_desc(opts)
        return {
            desc = opts[1],
            callback = opts[2],
        }
    end

    autocmd('FileType', {
        pattern = { 'r', 'rmd' },
        group = my_augroup,
        desc = 'set nvim-r keymap',
        callback = function()
            bufmap(0, 'n', '<Localleader>rs', '<Plug>RStart', opts_desc { 'R Start' })
            bufmap(0, 'n', '<Localleader>rq', '<Plug>RStop', opts_desc { 'R Stop' })
            bufmap(0, 'n', '<Localleader>rc', '<Plug>RClearConsole', opts_desc { 'R Clear' })
            bufmap(0, 'n', '<Localleader>rr', '<nop>', {})
            bufmap(0, 'n', '<Localleader>rh', '<nop>', {})
            bufmap(0, 'n', '<Localleader>rf', '<nop>', {})
            bufmap(0, 'n', '<Localleader>rw', '<nop>', {})
            bufmap(0, 'n', '<Localleader>ra', '<nop>', {})

            bufmap(0, 'n', '<Localleader>ss', '<Plug>RSendLine', opts_desc { 'R Send Current Line' })
            bufmap(0, 'n', '<Localleader>sm', '<Plug>RSendMBlock', opts_desc { 'R Send Between Two Marks' })
            bufmap(0, 'n', '<Localleader>sf', '<Plug>RSendFile', opts_desc { 'R Send Files' })
            bufmap(0, 'n', '<Localleader>s', '<Plug>RSendMotion', opts_desc { 'R Send Motion' })
            bufmap(0, 'n', '<Localleader>s<CR>', '<nop>', {})
            bufmap(0, 'v', '<Localleader>s', '<Plug>RSendSelection', opts_desc { 'R Send Selected Lines' })

            bufmap(0, 'n', '<Localleader>oh', '<Plug>RHelp', opts_desc { 'R object Help' })
            bufmap(0, 'n', '<Localleader>op', '<Plug>RObjectPr', opts_desc { 'R object Print' })
            bufmap(0, 'n', '<Localleader>os', '<Plug>RObjectStr', opts_desc { 'R object str' })
            bufmap(0, 'n', '<Localleader>oS', '<Plug>RSummary', opts_desc { 'R object summary' })
            bufmap(0, 'n', '<Localleader>on', '<Plug>RObjectNames', opts_desc { 'R object names' })
            bufmap(0, 'n', '<Localleader>oo', '<Plug>RUpdateObjBrowser', opts_desc { 'R object viewer open' })
            bufmap(0, 'n', '<Localleader>or', '<Plug>ROpenLists', opts_desc { 'R object open all lists' })
            bufmap(0, 'n', '<Localleader>om', '<Plug>RCloseLists', opts_desc { 'R object close all lists' })

            bufmap(0, 'n', '<Localleader>dt', '<Plug>RViewDF', opts_desc { 'R dataframe new tab' })
            bufmap(0, 'n', '<Localleader>ds', '<Plug>RViewDFs', opts_desc { 'R dataframe hsplit' })
            bufmap(0, 'n', '<Localleader>dh', '<Plug>RViewDFa', opts_desc { 'R dataframe head' })
            bufmap(0, 'n', '<Localleader>dv', '<Plug>RViewDFv', opts_desc { 'R dataframe vsplit' })
        end,
    })

    vim.cmd.packadd { 'Nvim-R', bang = true }
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
M.load.nvimr()

return M
