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

-- vim.cmd [[packadd! tabular]]
-- vim.cmd [[packadd! vim-markdown]]
--
-- vim.g.vim_markdown_folding_disabled = 1
-- vim.g.vim_markdown_auto_extension_ext = 'rmd'
-- vim.g.vim_markdown_auto_insert_bullets = 0
-- vim.g.vim_markdown_new_list_item_indent = 0
-- vim.g.vim_markdown_math = 1
-- vim.g.vim_markdown_frontmatter = 1
-- vim.g.vim_markdown_no_default_key_mappings = 1
--
-- vim.g.vim_markdown_fenced_languages = {
--     'bash=sh',
-- }

