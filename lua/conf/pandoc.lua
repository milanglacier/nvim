vim.cmd [[packadd! vim-pandoc-syntax]]
vim.cmd [[packadd! vim-rmarkdown]]

vim.cmd [[

augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

]]

vim.g.r_indent_align_args = 0
vim.g.r_indent_ess_comments = 0
vim.g.r_indent_ess_compatible = 0

-- vim.g['pandoc#syntax#conceal#blacklist'] = {'subscript', 'superscript', 'atx'}
vim.g['pandoc#syntax#codeblocks#embeds#langs'] = { 'python', 'R=r', 'r', 'bash=sh', 'json' }
