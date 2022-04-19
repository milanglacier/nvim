local M = {}

M.load = {}

M.load.autopairs = function()
    vim.cmd [[packadd! nvim-autopairs]]
    require('nvim-autopairs').setup {}
end

M.load.colorizer = function()
    vim.cmd [[packadd! nvim-colorizer.lua]]
    require('colorizer').setup()
end

M.load.comment = function()
    require('Comment').setup()
end

M.load.dsf = function()

    local augroup = vim.api.nvim_create_augroup
    local autocmd = vim.api.nvim_create_autocmd

    local dsf_for_rmd = augroup('DsfForRmd', {})
    autocmd('FileType', {
        group = dsf_for_rmd,
        pattern = 'rmd',
        callback = function()
            local bufmap = vim.api.nvim_buf_set_keymap
            bufmap(0, 'o', 'ae', '<Plug>DsfTextObjectA', { silent = true })
            bufmap(0, 'o', 'ie', '<Plug>DsfTextObjectI', { silent = true })
            bufmap(0, 'x', 'ae', '<Plug>DsfTextObjectA', { silent = true })
            bufmap(0, 'x', 'ie', '<Plug>DsfTextObjectI', { silent = true })
        end,
        desc = 'set ae/ie keymaps from dsf.vim for rmd.'
    })

    vim.g.dsf_no_mappings = 1
    local keymap = vim.api.nvim_set_keymap

    keymap('n', 'dsf', '<Plug>DsfDelete', { silent = true })
    keymap('n', 'csf', '<Plug>DsfChange', { silent = true })
    keymap('n', 'dsnf', '<Plug>DsfNextDelete', { silent = true })
    keymap('n', 'csnf', '<Plug>DsfNextChange', { silent = true })
end

M.load.matchup = function()
    local keymap = vim.api.nvim_set_keymap

    keymap('n', '<localleader>%', '<plug>(matchup-z%)', {})
    keymap('o', '<localleader>%', '<plug>(matchup-z%)', {})
    keymap('x', '<localleader>%', '<plug>(matchup-z%)', {})
end

M.load.sneak = function()
    if vim.g.vscode then
        vim.g['sneak#label'] = 0
    else
        vim.g['sneak#label'] = 1
    end

    vim.g['sneak#use_ic_scs'] = 1

    local keymap = vim.api.nvim_set_keymap

    keymap('', 'f', '<Plug>Sneak_f', {})
    keymap('', 'F', '<Plug>Sneak_F', {})
    keymap('', 't', '<Plug>Sneak_t', {})
    keymap('', 'T', '<Plug>Sneak_T', {})
end

M.load.targets = function()
    vim.g.targets_nl = { 'n', 'N' }
end

M.load.substitute = function()
    require('substitute').setup()

    local keymap = vim.api.nvim_set_keymap

    keymap('n', 'gs', "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
    keymap('n', 'gss', "<cmd>lua require('substitute').line()<cr>", { noremap = true })
    keymap('n', 'gS', "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
    keymap('x', 'gs', "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
end

M.load.textobj = function()
    vim.g.textobj_between_no_default_key_mappings = 1
    vim.g.textobj_chainmember_no_default_key_mappings = 1

    local keymap = vim.api.nvim_set_keymap

    keymap('x', 'ab', '<Plug>(textobj-between-a)', { noremap = true, silent = true })
    keymap('o', 'ab', '<Plug>(textobj-between-a)', { noremap = true, silent = true })
    keymap('x', 'ib', '<Plug>(textobj-between-i)', { noremap = true, silent = true })
    keymap('o', 'ib', '<Plug>(textobj-between-i)', { noremap = true, silent = true })

    keymap('x', 'a.', '<Plug>(textobj-chainmember-a)', { noremap = true, silent = true })
    keymap('o', 'i.', '<Plug>(textobj-chainmember-i)', { noremap = true, silent = true })
    keymap('x', 'a.', '<Plug>(textobj-chainmember-a)', { noremap = true, silent = true })
    keymap('o', 'i.', '<Plug>(textobj-chainmember-i)', { noremap = true, silent = true })
end

M.load.colorizer = function()
    vim.cmd [[packadd! nvim-colorizer.lua]]
    require('colorizer').setup()
end

if not vim.g.vscode then
    M.load.colorizer()
    M.load.autopairs()
end

M.load.comment()
M.load.dsf()
M.load.matchup()
M.load.sneak()
M.load.substitute()
M.load.targets()
M.load.textobj()

return M
