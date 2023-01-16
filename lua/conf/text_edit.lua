local M = {}

M.load = {}

local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap

M.load.autopairs = function()
    vim.cmd.packadd { 'nvim-autopairs', bang = true }
    require('nvim-autopairs').setup {}
end

M.load.mini_pairs = function()
    vim.cmd.packadd { 'mini.nvim', bang = true }
    require('mini.pairs').setup {}
end

M.load.comment = function()
    vim.cmd.packadd { 'Comment.nvim', bang = true }
    require('Comment').setup()
end

M.load.mini_comment = function()
    vim.cmd.packadd { 'mini.nvim', bang = true }
    require('mini.comment').setup {
        hooks = {
            pre = function()
                require('ts_context_commentstring.internal').update_commentstring()
            end,
        },
    }
end

M.load.dsf = function()
    autocmd('FileType', {
        group = my_augroup,
        pattern = 'rmd',
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
end

M.load.matchup = function()
    -- don't need this binding
    keymap('n', '%', '<plug>(matchup-z%)', {})
    keymap('o', '%', '<plug>(matchup-z%)', {})
    keymap('x', '%', '<plug>(matchup-z%)', {})
end

M.load.sneak = function()
    if vim.g.vscode then
        vim.g['sneak#label'] = 0
    else
        vim.g['sneak#label'] = 1
    end

    vim.g['sneak#use_ic_scs'] = 1

    keymap('', 'f', '<Plug>Sneak_f', {})
    keymap('', 'F', '<Plug>Sneak_F', {})
    keymap('', 't', '<Plug>Sneak_t', {})
    keymap('', 'T', '<Plug>Sneak_T', {})
end

M.load.targets = function()
    vim.cmd.packadd { 'targets.vim', bang = true }
    vim.g.targets_nl = { 'n', 'N' }
end

M.load.mini_ai = function()
    vim.cmd.packadd { 'mini.nvim', bang = true }
    require('mini.ai').setup {
        search_method = 'cover',
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

M.load.surround = function()
    vim.cmd.packadd { 'vim-surround', bang = true }
end

M.load.mini_surround = function()
    vim.cmd.packadd { 'mini.nvim', bang = true }
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
    vim.cmd.packadd { 'vim-textobj-chainmember', bang = true }
    vim.cmd.packadd { 'vim-textobj-between', bang = true }

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
end

M.load.colorizer = function()
    vim.cmd.packadd { 'nvim-colorizer.lua', bang = true }
    require('colorizer').setup()
end

M.load.easy_align = function()
    keymap('x', 'ga', '<Plug>(EasyAlign)', {})
    keymap('n', 'ga', '<Plug>(EasyAlign)', {})
end

M.load.mini_block_move = function()
    vim.cmd.packadd { 'mini.nvim', bang = true }
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

M.rm_trailing_space = function()
    vim.cmd [[%s/\s\+$//e]]
end

keymap('n', '<Leader>m<space>', '', {
    callback = M.rm_trailing_space,
    desc = 'Misc: remove trailing spaces',
})

if not vim.g.vscode then
    M.load.colorizer()
    M.load.mini_pairs()
end

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

return M
