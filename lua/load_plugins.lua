if not vim.g.vscode then

    vim.cmd [[    

    call plug#begin()

    Plug 'lewis6991/impatient.nvim'
    Plug 'nathom/filetype.nvim'

    Plug 'EdenEast/nightfox.nvim'
    Plug 'rose-pine/neovim', {'as': 'rose-pine'}
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'sainnhe/everforest'
    Plug 'mhdahmad/gruvbox.lua'

    " Fix bugs and Utilities
    Plug 'antoinemadec/FixCursorHold.nvim'
    Plug 'max397574/better-escape.nvim'

    " Set the theme for statusbar
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'alvarosevilla95/luatab.nvim'
    Plug 'rcarriga/nvim-notify'
    Plug 'echasnovski/mini.nvim'

    "automatically set the root
    Plug 'ygm2/rooter.nvim'
    Plug 'ahmedkhalf/project.nvim'

    " Set the advanced text editing and jumping plug
    Plug 'justinmk/vim-sneak'

    Plug 'ur4ltz/surround.nvim'
    Plug 'numToStr/Comment.nvim'
    Plug 'tpope/vim-repeat'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'wellle/targets.vim'
    Plug 'AndrewRadev/dsf.vim'
    Plug 'windwp/nvim-autopairs'
    Plug 'gbprod/substitute.nvim'
    Plug 'andymass/vim-matchup'
    Plug 'tommcdo/vim-exchange'

    Plug 'norcalli/nvim-colorizer.lua'

    " Tree sitter for enhanced text obj and syntax capturality
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'p00f/nvim-ts-rainbow'
    Plug 'mfussenegger/nvim-treehopper'

    " Set markdown syntax highlighting
    Plug 'vim-pandoc/vim-pandoc-syntax' , {'for': ['rmd', 'markdown.pandoc']}
    Plug 'vim-pandoc/vim-rmarkdown' ,  {'branch': 'official-filetype', 'for': 'rmd'}
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
    Plug 'tami5/lspsaga.nvim'
    Plug 'stevearc/aerial.nvim', {'on': 'AerialToggle'}
    Plug 'onsails/lspkind-nvim'
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'ThePrimeagen/refactoring.nvim'

    " lua development
    Plug 'folke/lua-dev.nvim'

    " REPL
    " Plug 'jalvesaq/Nvim-R', {'for': ['r', 'rmd']}
    " Plug 'jalvesaq/vimcmdline'
    Plug 's1n7ax/nvim-terminal'
    Plug 'hkupty/iron.nvim'


    " Git
    Plug 'lewis6991/gitsigns.nvim'
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

    ]]

else

    vim.cmd [[

    call plug#begin()

    Plug 'lewis6991/impatient.nvim'
    Plug 'nathom/filetype.nvim'

    " Fix bugs
    Plug 'antoinemadec/FixCursorHold.nvim'

    Plug 'justinmk/vim-sneak'

    Plug 'ur4ltz/surround.nvim'
    Plug 'numToStr/Comment.nvim'
    Plug 'tpope/vim-repeat'
    Plug 'wellle/targets.vim'
    Plug 'AndrewRadev/dsf.vim'
    Plug 'michaeljsmith/vim-indent-object'
    Plug 'gbprod/substitute.nvim'
    Plug 'andymass/vim-matchup'
    Plug 'tommcdo/vim-exchange'

    " Tree sitter for enhanced text obj and syntax capturality
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'mfussenegger/nvim-treehopper'

    " Deal with input method, automatically changed to English
    " input method when switch to normal mode
    Plug 'milanglacier/smartim'

    call plug#end()

    ]]

end
