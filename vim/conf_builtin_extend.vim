
" keybinding remap for global keys

inoremap jk <Esc>
tnoremap jk <C-\><C-n> 

" let g:mapleader = ' '
" let ctrl-a move to the beginning of the line

" Enable emacs style keybinding in insert mode
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-p> <Up>
inoremap <C-n> <Down>
inoremap <C-h> <BS>
inoremap <C-k> <ESC>d$i
inoremap <C-a> <home>
inoremap <C-e> <end>

tnoremap <C-b> <Left>
tnoremap <C-f> <Right>
tnoremap <C-p> <Up>
tnoremap <C-n> <Down>
tnoremap <C-h> <BS>
tnoremap <C-k> <ESC>d$i
tnoremap <C-a> <home>
tnoremap <C-e> <end>

" change working directory to current or one upper level
nnoremap <Leader>cd :cd %:h<cr>
nnoremap <Leader>cu :cd ..<cr>

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=400}
augroup END
