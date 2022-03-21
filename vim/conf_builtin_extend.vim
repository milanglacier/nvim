" keybinding remap for global keys
inoremap jk <Esc>
tnoremap jk <C-\><C-n> 

let mapleader = ' '
map <space><space> <LocalLeader>
map <BS> <LocalLeader>

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

" jump between buffers
nnoremap ]b :bn<cr>
nnoremap [b :bp<cr>

" let g:cursorhold_updatetime = 750

augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=400}
augroup END

let g:ping_cursor_flash_milliseconds = 400

function! s:PingCursor()
  set cursorline cursorcolumn
  redraw
  execute 'sleep' g:ping_cursor_flash_milliseconds . 'm'
  set nocursorline nocursorcolumn
endfunction

command PingCursor :call s:PingCursor()
noremap <leader>pc :PingCursor<cr>
