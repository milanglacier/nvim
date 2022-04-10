vim.cmd [[
augroup dsfForRmd
    au!
    autocmd FileType rmd omap <silent><buffer> ae <Plug>DsfTextObjectA
    autocmd FileType rmd xmap <silent><buffer> ae <Plug>DsfTextObjectA
    autocmd FileType rmd omap <silent><buffer> ie <Plug>DsfTextObjectI
    autocmd FileType rmd xmap <silent><buffer> ie <Plug>DsfTextObjectI
augroup end
]]

vim.g.dsf_no_mappings = 1
local keymap = vim.api.nvim_set_keymap

keymap('n', 'dsf', '<Plug>DsfDelete', {silent = true})
keymap('n', 'csf', '<Plug>DsfChange', {silent = true})
keymap('n', 'dsnf', '<Plug>DsfNextDelete', {silent = true})
keymap('n', 'csnf', '<Plug>DsfNextChange', {silent = true})
