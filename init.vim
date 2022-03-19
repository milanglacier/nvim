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

    syntax enable
    set mouse=a

    call plug#begin()

    Plug 'lewis6991/impatient.nvim'
    Plug 'nathom/filetype.nvim'

    Plug 'EdenEast/nightfox.nvim'
    Plug 'rose-pine/neovim', {'as': 'rose-pine'}
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'sainnhe/everforest'
    Plug 'mhdahmad/gruvbox.lua'

    " Fix bugs and Utilites
    Plug 'antoinemadec/FixCursorHold.nvim'
    Plug 'max397574/better-escape.nvim'

    " Set the theme for statusbar
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'alvarosevilla95/luatab.nvim'
    Plug 'rcarriga/nvim-notify'

    "automatically set the root
    Plug 'ygm2/rooter.nvim'
    Plug 'ahmedkhalf/project.nvim'

    " Set the advanced text editing and jumping plug
    Plug 'searleser97/vim-sneak'

    Plug 'tpope/vim-surround'
    Plug 'numToStr/Comment.nvim'
    Plug 'tpope/vim-repeat'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'wellle/targets.vim'
    Plug 'AndrewRadev/dsf.vim'
    Plug 'windwp/nvim-autopairs'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'gbprod/substitute.nvim'
    Plug 'andymass/vim-matchup'

    Plug 'norcalli/nvim-colorizer.lua'

    " Tree sitter for enhanced text obj and syntax capturality
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'p00f/nvim-ts-rainbow'
    Plug 'mfussenegger/nvim-treehopper'

    " Set markdown syntax highlighting
    Plug 'vim-pandoc/vim-pandoc-syntax', {'for': ['rmd', 'markdown.pandoc']}
    Plug 'vim-pandoc/vim-rmarkdown', {'for': ['rmd'], 'branch': 'official-filetype'}
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
    Plug 'kyazdani42/nvim-tree.lua', {'on': 'NvimTreeToggle'}

    " LSP config
    Plug 'neovim/nvim-lspconfig'
    Plug 'tami5/lspsaga.nvim'

    " Completion
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lua'
    Plug 'hrsh7th/cmp-omni'
    Plug 'kdheepak/cmp-latex-symbols'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'saadparwaiz1/cmp_luasnip'

    " Symbol Outline and signature help
    Plug 'stevearc/aerial.nvim', {'on': 'AerialToggle'}
    Plug 'onsails/lspkind-nvim'
    Plug 'ray-x/lsp_signature.nvim'

    " REPL
    " Plug 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
    " Plug 'jalvesaq/vimcmdline'
    Plug 's1n7ax/nvim-terminal'
    Plug 'hkupty/iron.nvim'


    " Git
    Plug 'f-person/git-blame.nvim'
    Plug 'TimUntersberger/neogit', {'on': 'Neogit'}
    Plug 'sindrets/diffview.nvim', {'on': ['DiffviewOpen', 'DiffviewFileHistory']}

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

    lua require("impatient").enable_profile()

    lua require("conf_filetype")

    source ~/.config/nvim/vim/conf_builtin_extend.vim
    source ~/.config/nvim/vim/conf_move_tabs.vim

    lua require("conf_better_escape")

    lua require("conf_colorscheme")

    lua require('conf_lualine')
    lua require('conf_notify')
    lua require('conf_indent')
    lua require('conf_luatab')


    lua require('conf_comment')
    source ~/.config/nvim/vim/conf_dsf.vim
    lua require('conf_substitute')
    source ~/.config/nvim/vim/conf_targets.vim
    source ~/.config/nvim/vim/conf_matchup.vim


    lua require("conf_treesitter")

    lua require('conf_nvim_tree')

    lua require('conf_telescope')
    lua require('conf_project_nvim')

    lua require("conf_lspkind")
    lua require("conf_aerial")

    lua require('conf_cmp')
    lua require('conf_saga')
    lua require('conf_lspconfig')
    lua require('conf_signature')

    source ~/.config/nvim/vim/conf_pandoc.vim
    " source ~/.config/nvim/vim/conf_nvim-R.vim
    " source ~/.config/nvim/vim/conf_cmdline.vim
    lua require("conf_iron")

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


    Plug 'lewis6991/impatient.nvim'
    Plug 'nathom/filetype.nvim'

    " Fix bugs
    Plug 'antoinemadec/FixCursorHold.nvim'

    Plug 'searleser97/vim-sneak'

    Plug 'tpope/vim-surround'
    Plug 'numToStr/Comment.nvim'
    Plug 'tpope/vim-repeat'
    Plug 'wellle/targets.vim'
    Plug 'AndrewRadev/dsf.vim'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'gbprod/substitute.nvim'
    Plug 'andymass/vim-matchup'

    " Tree sitter for enhanced text obj and syntax capturality
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'mfussenegger/nvim-treehopper'

    " Deal with input method, automatically changed to English
    " input method when switch to normal mode
    Plug 'milanglacier/smartim'
    Plug 'asvetliakov/vim-easymotion'

    call plug#end()

    lua require("impatient")
    lua require("conf_filetype")

    source ~/.config/nvim/vim/conf_builtin_extend.vim

    lua require('conf_comment')
    lua require('conf_substitute')
    source ~/.config/nvim/vim/conf_dsf.vim
    source ~/.config/nvim/vim/conf_targets.vim
    source ~/.config/nvim/vim/conf_matchup.vim
    lua require("conf_treesitter")
    source ~/.config/nvim/vim/conf_sneak.vim


endif




