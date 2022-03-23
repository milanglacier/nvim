vim.cmd [[

augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

autocmd BufRead,BufNewFile *.jl      set filetype=julia

]]

vim.g.r_indent_align_args = 0
vim.g.r_indent_ess_comments = 0
vim.g.r_indent_ess_compatible = 0

-- vim.g['pandoc#syntax#conceal#blacklist'] = {'subscript', 'superscript', 'atx'}
