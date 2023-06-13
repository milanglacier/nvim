local M = {}

M.load = {}

local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap

local lazy = require 'lazy'

M.load.mini_pairs = function()
    require('mini.pairs').setup {}
end

M.load.mini_comment = function()
    require('mini.comment').setup {}
end

M.load.dsf = function()
    autocmd('FileType', {
        group = my_augroup,
        pattern = { 'rmd', 'quarto' },
        callback = function()
            local bufmap = vim.api.nvim_buf_set_keymap
            bufmap(0, 'o', 'ae', '<Plug>DsfTextObjectA', { silent = true })
            bufmap(0, 'o', 'ie', '<Plug>DsfTextObjectI', { silent = true })
            bufmap(0, 'x', 'ae', '<Plug>DsfTextObjectA', { silent = true })
            bufmap(0, 'x', 'ie', '<Plug>DsfTextObjectI', { silent = true })
        end,
        desc = 'set ae/ie keymaps from dsf.vim for rmd.',
    })

    vim.g.dsf_no_mappings = 1

    keymap('n', 'dsf', '<Plug>DsfDelete', { silent = true })
    keymap('n', 'csf', '<Plug>DsfChange', { silent = true })
    keymap('n', 'dsnf', '<Plug>DsfNextDelete', { silent = true })
    keymap('n', 'csnf', '<Plug>DsfNextChange', { silent = true })

    lazy.load { plugins = { 'dsf.vim' } }
end

M.load.matchup = function()
    -- don't need this binding, remap them to some keys not likely to trigger
    keymap('n', '%', '<plug>(matchup-z%)', {})
    keymap('o', '%', '<plug>(matchup-z%)', {})
    keymap('x', '%', '<plug>(matchup-z%)', {})
    keymap('i', '%', '<plug>(matchup-c_g%)', {})
end

M.load.sneak = function()
    vim.g['sneak#label'] = 1

    vim.g['sneak#use_ic_scs'] = 1

    keymap('', 'f', '<Plug>Sneak_f', {})
    keymap('', 'F', '<Plug>Sneak_F', {})
    keymap('', 't', '<Plug>Sneak_t', {})
    keymap('', 'T', '<Plug>Sneak_T', {})

    lazy.load { plugins = { 'vim-sneak' } }
end

M.load.mini_ai = function()
    require('mini.ai').setup {
        custom_textobjects = {
            -- See `echasnovski/mini.nvim #366`. Mini.ai does not handle quotes
            -- worse than vim's default.
            ['"'] = false,
            ["'"] = false,
        },
        mappings = {
            -- Next/last variants
            around_next = 'an',
            inside_next = 'in',
            around_last = 'aN',
            inside_last = 'iN',
            -- Move cursor to corresponding edge of `a` textobject
            goto_left = 'g(',
            goto_right = 'g)',
        },
        n_lines = 100,
    }
end

M.load.mini_surround = function()
    require('mini.surround').setup {
        mappings = {
            add = '<Plug>(mini-surround-add)',
            delete = '<Plug>(mini-surround-delete)',
            find = '<Plug>(mini-surround-find)',
            find_left = '<Plug>(mini-surround-find_left)',
            highlight = '<Plug>(mini-surround-highlight)',
            replace = '<Plug>(mini-surround-replace)',
            update_n_lines = '<Plug>(mini-surround-update_n_lines)',
        },
    }

    keymap('n', 'ys', '<Plug>(mini-surround-add)', {})
    keymap('n', 'yss', '^ys$', {})
    keymap('n', 'yS', 'ys$', {})
    keymap('x', 'S', '<Plug>(mini-surround-add)', {})
    keymap('n', 'cs', '<Plug>(mini-surround-replace)', {})
    keymap('n', 'ds', '<Plug>(mini-surround-delete)', {})
end

M.load.substitute = function()
    require('substitute').setup {}

    keymap('n', 'gs', "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
    keymap('n', 'gss', "<cmd>lua require('substitute').line()<cr>", { noremap = true })
    keymap('n', 'gS', "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
    keymap('x', 'gs', "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
end

M.load.textobj = function()
    vim.g.textobj_between_no_default_key_mappings = 1
    vim.g.textobj_chainmember_no_default_key_mappings = 1

    keymap('x', 'ab', '<Plug>(textobj-between-a)', {})
    keymap('o', 'ab', '<Plug>(textobj-between-a)', {})
    keymap('x', 'ib', '<Plug>(textobj-between-i)', {})
    keymap('o', 'ib', '<Plug>(textobj-between-i)', {})

    keymap('o', 'a.', '<Plug>(textobj-chainmember-a)', {})
    keymap('o', 'i.', '<Plug>(textobj-chainmember-i)', {})
    keymap('x', 'a.', '<Plug>(textobj-chainmember-a)', {})
    keymap('x', 'i.', '<Plug>(textobj-chainmember-i)', {})

    lazy.load { plugins = { 'vim-textobj-user', 'vim-textobj-between', 'vim-textobj-chainmember' } }
end

M.load.colorizer = function()
    require('colorizer').setup()
end

M.load.easy_align = function()
    keymap('x', 'ga', '<Plug>(EasyAlign)', {})
    keymap('n', 'ga', '<Plug>(EasyAlign)', {})

    lazy.load { plugins = { 'vim-easy-align' } }
end

M.load.mini_block_move = function()
    require('mini.move').setup {
        mappings = {
            line_left = '',
            line_right = '',
            line_down = '',
            line_up = '',
            -- don't enable block move in normal mode
        },
    }
end

M.load.todo_comments = function()
    require('todo-comments').setup {}
end

M.load.dial = function()
    local augend = require 'dial.augend'
    local universal = {
        augend.integer.alias.decimal_int, -- nonnegative decimal number (0, 1, 2, 3, ...)
        augend.integer.alias.hex, -- nonnegative hex number  (0x01, 0x1a1f, etc.)
        augend.date.alias['%Y-%m-%d'], -- date (2022/02/19, etc.)
        augend.date.alias['%m/%d/%Y'], -- date (02/19/2022, etc.)
        augend.date.alias['%Y年%-m月%-d日'],
        augend.date.alias['%H:%M'],
        augend.date.alias['%H:%M:%S'],
        augend.constant.alias.bool, -- boolean value (true <-> false)
        augend.constant.new { elements = { 'and', 'or' } },
        augend.constant.new { elements = { 'True', 'False' } },
        augend.constant.new { elements = { 'TRUE', 'FALSE' } },
        augend.constant.new { elements = { '&&', '||' }, word = false },
        augend.constant.new { elements = { '&', '|' }, word = false },
        augend.date.new {
            pattern = '%Y-%m-%d %H:%M',
            default_kind = 'sec',
        },
    }
    require('dial.config').augends:register_group {
        default = universal,
    }
    keymap('n', '<C-a>', '<Plug>(dial-increment)', { desc = 'increment' })
    keymap('n', '<C-x>', '<Plug>(dial-decrement)', { desc = 'decrement' })
    keymap('x', '<C-a>', '<Plug>(dial-increment)', { desc = 'increment' })
    keymap('x', '<C-x>', '<Plug>(dial-decrement)', { desc = 'decrement' })
    keymap('x', 'g<C-a>', 'g<Plug>(dial-increment)', { desc = 'ordered increment' })
    keymap('x', 'g<C-x>', 'g<Plug>(dial-decrement)', { desc = 'ordered decrement' })
end

M.rm_trailing_space = function()
    vim.cmd [[%s/\s\+$//e]]
end

keymap('n', '<Leader>m<space>', '', {
    callback = M.rm_trailing_space,
    desc = 'Misc: remove trailing spaces',
})

M.load.colorizer()
M.load.mini_pairs()
M.load.todo_comments()

M.load.mini_comment()
M.load.dsf()
M.load.matchup()
M.load.sneak()
M.load.substitute()
M.load.mini_ai()
M.load.textobj()
M.load.mini_surround()
M.load.easy_align()
M.load.mini_block_move()
M.load.dial()

return M
