
" keybinding remap for global keys

inoremap jk <Esc>
" let g:mapleader = ' '
" let ctrl-a move to the beginning of the line
inoremap <C-a> <home>
inoremap <C-e> <end>

" Enable C-bpfn to move cursor when in editor mode
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-p> <Up>
inoremap <C-n> <Down>

nnoremap <Leader>cd :cd %:h<cr>
nnoremap <Leader>cu :cd ..<cr>

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=400}
augroup END
