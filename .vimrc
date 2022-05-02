filetype plugin indent on
syntax on

set modelines=0
set nocompatible
set backspace=2

set nowritebackup
set nobackup
set autoread

set number
set autoindent
set softtabstop=4
set expandtab
set shiftwidth=4
set showcmd
set ignorecase
set smartcase
set linebreak
set incsearch

set clipboard=unnamed
set completeopt=menu,menuone,noselect

set mouse=a
set termguicolors

let g:mapleader = ' '
let g:maplocalleader = '  '
map \ <LocalLeader>

inoremap jk <ESC>
inoremap <C-b> <Left>
inoremap <C-p> <Up>
inoremap <C-f> <Right>
inoremap <C-n> <Down>
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-h> <BS>
inoremap <C-k> <ESC>d$i

nnoremap D d$
nnoremap Y y$
nnoremap C c$

nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
nnoremap <Leader>to :tabonly<CR>
nnoremap <Leader>tn :tabnew<CR>
nnoremap <Leader>tc :tabclose<CR>

nnoremap <A-w> <C-W>w
nnoremap <A-p> <C-W>p
nnoremap <A-t> <C-W>T
nnoremap <A-q> <C-W>q
nnoremap <A-v> <C-W>v
nnoremap <A-s> <C-W>s
nnoremap <A-h> <C-W>h
nnoremap <A-j> <C-W>j
nnoremap <A-k> <C-W>k
nnoremap <A-l> <C-W>l
nnoremap <A-H> <C-W>H
nnoremap <A-J> <C-W>J
nnoremap <A-K> <C-W>K
nnoremap <A-L> <C-W>L

let g:highlightedyank_highlight_duration = 500
