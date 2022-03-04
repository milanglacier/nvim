" Configuration file for vim
set modelines=0		" CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible	" Use Vim defaults instead of 100% vi compatibility
set backspace=2		" more powerful backspacing

" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /private/tmp/crontab.* set nowritebackup nobackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /private/etc/pw.* set nowritebackup nobackup

let skip_defaults_vim=1


" above is the default setting when installing neovim. Will not change it
" following is my setting
set nu
set autoindent
set softtabstop=4 expandtab shiftwidth=4
set autoindent
set showcmd
set ignorecase smartcase

filetype plugin indent on


" set the terminal working at the current directory
" autocmd BufEnter * silent! lcd %:p:h

" you have to define your <leader> key very early
" as if you define your leader key to be <spc> 
" later than your map key which used <Leader>
" then you probably find that this map won't working.
let mapleader = ' '

set clipboard+=unnamedplus

" function to enabling the same plugin (at different fork), primarily
" for vscode neovim extension.
" to use it, you need to copy two lines of installation commamnd
" in !exists('g:vscode') branch, as you need to call
" `:PlugInstall` in nvim terminal to install the fork for Vscode
" function! Cond(Cond, ...)
"   let opts = get(a:000, 0, {})
"   return a:Cond ? opts : extend(opts, { 'on': [], 'for': [] })
" endfunction



let g:CONDA_PATHNAME = "/opt/homebrew/Caskroom/miniforge/base"

" condition brach for different setting in nvim terminal and vscode
if !exists('g:vscode')

    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
    set termguicolors
    set guifont=Code_new_Roman_Nerd_Font_Complete:h15

    call plug#begin()

        " Set the Theme for nvim
        " Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
        Plug 'EdenEast/nightfox.nvim'

        " Set the theme for statusbar
        Plug 'nvim-lualine/lualine.nvim'
        " Plug 'sunjon/shade.nvim'

        "automatically set the root
        Plug 'ygm2/rooter.nvim'

        " Set the advanced text editing and jumping plug
        Plug 'searleser97/vim-sneak'
        Plug 'tpope/vim-surround'
        " Plug 'preservim/nerdcommenter'
        Plug 'numToStr/Comment.nvim'
        Plug 'tpope/vim-repeat'
        " Plug 'vim-scripts/argtextobj.vim'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'wellle/targets.vim'
        Plug 'windwp/nvim-autopairs'
        Plug 'lukas-reineke/indent-blankline.nvim'

        " Tree sitter for enhanced text obj and syntax capturality
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        Plug 'nvim-treesitter/nvim-treesitter-textobjects'
        Plug 'p00f/nvim-ts-rainbow'

        " Set markdown syntax highlighting
        Plug 'vim-pandoc/vim-pandoc-syntax', {'for': ['r', 'rmd', 'python', 'markdown.pandoc']}
        Plug 'vim-pandoc/vim-rmarkdown', {'for': ['rmarkdown']}
        Plug 'iamcco/markdown-preview.nvim' , { 'do': 'cd app && yarn install', 'for': ['markdown.pandoc', 'rmd']  }

        " Fuzzy finder for file search
        Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-telescope/telescope.nvim'
        Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }

        " very simple, naive completion without LSP
        " Plug 'skywind3000/vim-auto-popmenu'
        " Plug 'skywind3000/vim-dict'

        " Deal with input method, automatically changed to English
        " input method when switch to normal mode
        Plug 'milanglacier/smartim'
        
        " support browser
        " Plug 'glacambre/firenvim'

        " file explorer
        Plug 'kyazdani42/nvim-tree.lua'

        " LSP config
        Plug 'neovim/nvim-lspconfig'
        Plug 'hrsh7th/cmp-nvim-lsp'
        Plug 'hrsh7th/cmp-buffer'
        Plug 'hrsh7th/cmp-path'
        Plug 'hrsh7th/cmp-cmdline'
        Plug 'hrsh7th/nvim-cmp'
        Plug 'tami5/lspsaga.nvim'


        " Completion
        Plug 'L3MON4D3/LuaSnip'
        Plug 'saadparwaiz1/cmp_luasnip'

        " Symbol Outline
        " Plug 'simrat39/symbols-outline.nvim'
        Plug 'stevearc/aerial.nvim'
        Plug 'onsails/lspkind-nvim'

        " REPL
        Plug 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
        Plug 'jalvesaq/vimcmdline'
        Plug 's1n7ax/nvim-terminal'

        " Git
        Plug 'f-person/git-blame.nvim'
        Plug 'TimUntersberger/neogit'
        Plug 'sindrets/diffview.nvim'

        " Debugger
        Plug 'mfussenegger/nvim-dap', {'for': ['python']}
        Plug 'mfussenegger/nvim-dap-python', {'for': ['python']}
        Plug 'rcarriga/nvim-dap-ui', {'for': ['python']}
        Plug 'nvim-telescope/telescope-dap.nvim', {'for': ['python']}
        Plug 'theHamsta/nvim-dap-virtual-text', {'for': ['python']}

        " search and replace file
        Plug 'windwp/nvim-spectre'


        Plug 'kyazdani42/nvim-web-devicons'


    call plug#end()

    " set shell=zsh

    syntax enable
    
lua << EOF

    time = os.date("*t")
    if (time.hour <= 7) or (time.hour >= 23) then
            vim.cmd("colorscheme nightfox")
    else
            vim.cmd("colorscheme dawnfox")
    end
EOF

    source ~/.config/nvim/vim/conf_builtin_extend.vim

    lua require('conf_lualine')
    lua require('conf_indent')
    " lua require('conf_shade')

    lua require('conf_comment')

    
    lua require("conf_treesitter")
    source ~/.config/nvim/vim/conf_pandoc.vim
    source ~/.config/nvim/vim/conf_nvim_tree.vim
    lua require('conf_nvim_tree')
    lua require('conf_telescope')

    lua require("conf_aerial")
    
    
    lua require('conf_cmp')
    lua require('conf_saga')
    lua require('conf_lspconfig')
    source ~/.config/nvim/vim/conf_nvim-R.vim
    source ~/.config/nvim/vim/conf_move_tabs.vim
    source ~/.config/nvim/vim/conf_cmdline.vim
    " lua require("conf_sym_otln")

    source ~/.config/nvim/vim/conf_mkdp.vim
    source ~/.config/nvim/vim/conf_sneak.vim

    lua require("conf_terminal")
    lua require("conf_autopairs")
    lua require("conf_snippets")

    lua require("conf_dap")

    lua require("conf_spectre")
    
    
else 
    " configuration only valid in vscode neovim mode 

    
    call plug#begin()

        Plug 'searleser97/vim-sneak'

        Plug 'tpope/vim-surround'
        " Plug 'preservim/nerdcommenter'
        Plug 'numToStr/Comment.nvim'
        Plug 'tpope/vim-repeat'
        " Plug 'vim-scripts/argtextobj.vim'
        Plug 'wellle/targets.vim'
        Plug 'michaeljsmith/vim-indent-object'

        " Tree sitter for enhanced text obj and syntax capturality
        Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
        Plug 'nvim-treesitter/nvim-treesitter-textobjects'

        " Deal with input method, automatically changed to English
        " input method when switch to normal mode
        Plug 'milanglacier/smartim'
        Plug 'asvetliakov/vim-easymotion'

    call plug#end()
    
    lua require('conf_comment')
    lua require("conf_treesitter")
    source ~/.config/nvim/vim/conf_sneak.vim
    source ~/.config/nvim/vim/conf_builtin_extend.vim

endif




