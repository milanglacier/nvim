require 'paq' {

    -- optimize startup
    'lewis6991/impatient.nvim',
    'nathom/filetype.nvim',

    -- colorschemes
    { 'EdenEast/nightfox.nvim', opt = true },
    { 'rose-pine/neovim', as = 'rose-pine', opt = true },
    { 'folke/tokyonight.nvim', branch = 'main', opt = true },
    { 'sainnhe/everforest', opt = true },
    { 'mhdahmad/gruvbox.lua', opt = true },
    { 'rebelot/kanagawa.nvim', opt = true },
    { 'savq/melange', opt = true },
    { 'catppuccin/nvim', as = 'catppuccin', opt = true },
    { 'marko-cerovac/material.nvim', opt = true },

    -- Fix bugs and Utilities
    { 'antoinemadec/FixCursorHold.nvim' },
    { 'max397574/better-escape.nvim', opt = true },
    { 'ygm2/rooter.nvim', opt = true },
    { 'ahmedkhalf/project.nvim', opt = true },
    { 'kyazdani42/nvim-tree.lua', opt = true }, -- file explorer
    { 'milanglacier/smartim', opt = true }, -- automatically switch input method when switch mode
    { 'sindrets/winshift.nvim', opt = true },
    -- very simple, naive completion without LSP
    -- Plug 'skywind3000/vim-auto-popmenu'
    -- Plug 'skywind3000/vim-dict'
    -- support browser
    -- Plug 'glacambre/firenvim'

    -- UI
    { 'MunifTanjim/nui.nvim', opt = true },
    { 'nvim-lualine/lualine.nvim', opt = true },
    { 'alvarosevilla95/luatab.nvim', opt = true },
    { 'rcarriga/nvim-notify', opt = true },
    { 'echasnovski/mini.nvim', opt = true },
    { 'folke/trouble.nvim', opt = true },
    { 'xiyaowong/nvim-transparent', opt = true },
    { 'kyazdani42/nvim-web-devicons', opt = true },

    -- text-editing, motions, jumps tools
    { 'justinmk/vim-sneak' },
    { 'tpope/vim-surround' },
    { 'numToStr/Comment.nvim' },
    { 'tpope/vim-repeat' },
    { 'michaeljsmith/vim-indent-object' },
    { 'wellle/targets.vim' },
    { 'AndrewRadev/dsf.vim' },
    { 'gbprod/substitute.nvim' },
    { 'andymass/vim-matchup' },
    { 'tommcdo/vim-exchange' },
    { 'kana/vim-textobj-user' },
    { 'D4KU/vim-textobj-chainmember' },
    { 'thinca/vim-textobj-between' },

    -- text editing tools only for nvim
    { 'norcalli/nvim-colorizer.lua', opt = true },
    { 'windwp/nvim-autopairs', opt = true },

    -- Tree sitter for enhanced text obj and syntax capturality
    { 'nvim-treesitter/nvim-treesitter' },
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    { 'p00f/nvim-ts-rainbow' },
    { 'mfussenegger/nvim-treehopper', opt = true },
    { 'mizlan/iswap.nvim', opt = true },
    { 'romgrk/nvim-treesitter-context', opt = true },

    -- Set markdown/rmd syntax highlighting
    { 'vim-pandoc/vim-pandoc-syntax', opt = true },
    { 'vim-pandoc/vim-rmarkdown', branch = 'official-filetype', opt = true },

    -- Fuzzy finder for file search
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim', opt = true },
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', opt = true },

    -- LSP config
    { 'neovim/nvim-lspconfig', opt = true },

    -- lsp related tools, including lsp symbols, symbol outline, etc.
    { 'tami5/lspsaga.nvim', opt = true },
    { 'stevearc/aerial.nvim', opt = true },
    { 'onsails/lspkind-nvim', opt = true },
    { 'ray-x/lsp_signature.nvim', opt = true },
    { 'jose-elias-alvarez/null-ls.nvim', opt = true },
    { 'ThePrimeagen/refactoring.nvim', opt = true },

    -- Completion
    { 'hrsh7th/cmp-nvim-lsp', opt = true },
    { 'hrsh7th/cmp-buffer', opt = true },
    { 'hrsh7th/cmp-path', opt = true },
    { 'hrsh7th/cmp-cmdline', opt = true },
    { 'hrsh7th/nvim-cmp', opt = true },
    { 'hrsh7th/cmp-nvim-lua', opt = true },
    { 'hrsh7th/cmp-omni', opt = true },
    { 'kdheepak/cmp-latex-symbols', opt = true },
    { 'L3MON4D3/LuaSnip', opt = true },
    { 'saadparwaiz1/cmp_luasnip', opt = true },
    { 'rafamadriz/friendly-snippets', opt = true },

    -- language development
    { 'folke/lua-dev.nvim', opt = true },
    { 'nanotee/sqls.nvim', opt = true },

    -- CLI tools

    -- REPL
    -- 'jalvesaq/Nvim-R',
    -- 'jalvesaq/vimcmdline',
    { 's1n7ax/nvim-terminal', opt = true },
    { 'hkupty/iron.nvim', opt = true },

    -- Git
    { 'lewis6991/gitsigns.nvim', opt = true },
    { 'TimUntersberger/neogit', opt = true },
    { 'sindrets/diffview.nvim', opt = true },

    -- Other cli tools, ripgrep, hover, markdown, etc
    { 'windwp/nvim-spectre', opt = true },
    { 'JASONews/glow-hover', opt = true },
    { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', opt = true },

    -- Debugger
    { 'mfussenegger/nvim-dap', opt = true },
    { 'mfussenegger/nvim-dap-python', opt = true },
    { 'rcarriga/nvim-dap-ui', opt = true },
    { 'nvim-telescope/telescope-dap.nvim', opt = true },
    { 'theHamsta/nvim-dap-virtual-text', opt = true },
}
