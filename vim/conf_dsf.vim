let g:dsf_no_mappings = 1

nmap <silent> dsf <Plug>DsfDelete
nmap <silent> csf <Plug>DsfChange

nmap <silent> dsnf <Plug>DsfNextDelete
nmap <silent> csnf <Plug>DsfNextChange

augroup dsfForRmd
    au!
    autocmd FileType rmd omap <silent><buffer> ae <Plug>DsfTextObjectA
    autocmd FileType rmd xmap <silent><buffer> ae <Plug>DsfTextObjectA
    autocmd FileType rmd omap <silent><buffer> ie <Plug>DsfTextObjectI
    autocmd FileType rmd xmap <silent><buffer> ie <Plug>DsfTextObjectI
augroup end
