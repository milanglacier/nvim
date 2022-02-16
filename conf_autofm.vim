
" use vim-pandoc-syntax without vim-pandoc
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END

autocmd BufRead,BufNewFile *.jl      set filetype=julia

" Create mapping for filetype-formatter only for
" py and r, rmd, md, and julia
" NOTE THAT:
" as I redefine filetype of .md as markdown.pandoc
" I have to redefine the formatting behavior of markdown.pandoc
" in the source code of the plug vim-filetype-formatter 
" (need to locate where it is)

augroup autoformat_mappings
    autocmd!
    autocmd FileType r,rmd,python,markdown.pandoc nnoremap <silent> <leader>fl :FiletypeFormat<cr>
    autocmd FileType r,rmd,python,markdown.pandoc vnoremap <silent> <leader>fl :FiletypeFormat<cr>
augroup END

autocmd FileType julia nnoremap <leader>fl :JuliaFormatterFormat<CR>
autocmd FileType julia vnoremap <leader>fl :JuliaFormatterFormat<CR>

" Let the code-formatter plugin to enable format R, py

if has('nvim') && !empty(CONDA_PATHNAME)
let g:vim_filetype_formatter_commands = {
\ 'r': 'Rscript ~/.config/nvim/format/fmt.R',
\ 'rmarkdown': 'Rscript ~/.config/nvim/format/fmt.R',
\ 'python': CONDA_PATHNAME . '/bin/python -m black -q -'
\ }
endif

" Set up for simple code completion
" enable this plugin for filetypes, '*' for all files.
"
" NOTE THAT:
" in order to make R completion available, I manually create 
" a R, python and Julia dictionary and 
" put the .dict file into the corresponding place
" where the plug folder is located
" let g:apc_enable_ft = {'*':1}
" source for dictionary, current or other loaded buffers, see ':help cpt'
" set cpt=.,k,w,b
" don't select the first item.
" set completeopt=menu,menuone,noselect
" suppress annoy messages.
" set shortmess+=c

" change the indentation style for R
" ie the newline indentatino for () is identical to {}
let r_indent_align_args = 0
let r_indent_ess_comments = 0
let r_indent_ess_compatible = 0
