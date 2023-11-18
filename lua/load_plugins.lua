local lazy_plugins = {
    { 'folke/lazy.nvim' },

    -- colorschemes
    { 'EdenEast/nightfox.nvim' },
    { 'rose-pine/neovim', name = 'rose-pine' },
    { 'folke/tokyonight.nvim', branch = 'main' },
    { 'sainnhe/everforest' },
    { 'sainnhe/edge' },
    { 'ellisonleao/gruvbox.nvim' },
    { 'rebelot/kanagawa.nvim' },
    { 'catppuccin/nvim', name = 'catppuccin' },

    -- Fix bugs and Utilities
    { 'ahmedkhalf/project.nvim' },
    { 'kyazdani42/nvim-tree.lua' }, -- file explorer
    { 'sindrets/winshift.nvim' },

    -- UI
    { 'nvim-lualine/lualine.nvim' },
    { 'rcarriga/nvim-notify' },
    { 'echasnovski/mini.nvim' },
    { 'folke/trouble.nvim' },
    { 'folke/which-key.nvim' },
    { 'lukas-reineke/indent-blankline.nvim' },
    { 'kyazdani42/nvim-web-devicons' },

    -- text-editing, motions, jumps tools
    { 'justinmk/vim-sneak' },
    { 'junegunn/vim-easy-align' },
    { 'tpope/vim-repeat', lazy = false },
    { 'michaeljsmith/vim-indent-object', lazy = false },
    { 'AndrewRadev/dsf.vim' },
    { 'gbprod/substitute.nvim' },
    { 'andymass/vim-matchup', event = 'VeryLazy' },
    { 'tommcdo/vim-exchange', lazy = false },
    { 'kana/vim-textobj-user' },
    { 'D4KU/vim-textobj-chainmember' },
    { 'thinca/vim-textobj-between' },
    { 'monaqa/dial.nvim' },

    -- text editing tools only for nvim
    { 'norcalli/nvim-colorizer.lua' },
    { 'folke/todo-comments.nvim' },

    -- Tree sitter for enhanced text obj and syntax capturality
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
            { 'mfussenegger/nvim-treehopper' },
            { 'mizlan/iswap.nvim' },
            { 'romgrk/nvim-treesitter-context' },
            { 'cshuaimin/ssr.nvim' },
        },
    },

    { 'HiPhish/rainbow-delimiters.nvim' },

    -- Set markdown/rmd/quarto syntax highlighting
    { 'vim-pandoc/vim-pandoc-syntax' },
    { 'vim-pandoc/vim-rmarkdown', branch = 'official-filetype' },
    { 'quarto-dev/quarto-vim' },

    -- Fuzzy finder for file search
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope.nvim' },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- LSP config
    { 'neovim/nvim-lspconfig' },

    -- lsp related tools, including lsp symbols, symbol outline, etc.
    { 'glepnir/lspsaga.nvim' },
    { 'stevearc/aerial.nvim' },
    { 'onsails/lspkind-nvim' },
    { 'ray-x/lsp_signature.nvim' },
    { 'ThePrimeagen/refactoring.nvim' },
    { 'SmiteshP/nvim-navic' },

    -- Completion

    -- nvim-lspconfig requires cmp-nvim-lsp, so we shouldn't consider
    -- cmp-nvim-lsp as dependencies of nvim-cmp because all the dependencies
    -- will be loaded at once.
    { 'hrsh7th/cmp-nvim-lsp' },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-cmdline' },
            {
                'L3MON4D3/LuaSnip',
                dependencies = {
                    { 'rafamadriz/friendly-snippets' },
                },
            },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'quangnguyen30192/cmp-nvim-tags' },
            { 'petertriho/cmp-git' },
            -- { 'jalvesaq/cmp-nvim-r' },
        },
    },

    -- language development
    { 'folke/neodev.nvim' },
    { 'nanotee/sqls.nvim' },

    -- cli tools

    -- installer
    { 'williamboman/mason.nvim' },
    -- neovim installer that helps you to install external command line
    -- programs

    -- REPL
    -- { 'jalvesaq/Nvim-R' },
    { 'akinsho/toggleterm.nvim' },
    { 'goerz/jupytext.vim' },
    { 'milanglacier/yarepl.nvim' },

    -- Git
    { 'lewis6991/gitsigns.nvim' },
    { 'NeogitOrg/neogit' },
    { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewFileHistory' } },

    -- Other cli tools, ripgrep, hover, markdown, etc
    { 'nvim-pack/nvim-spectre' },
    -- { 'iamcco/markdown-preview.nvim', build = 'cd app && npm install' },
    { 'ludovicchabant/vim-gutentags' },
    { 'nvim-orgmode/orgmode' },
    { 'lervag/vimtex' },
    { 'jmbuhr/otter.nvim' },
    -- { 'zbirenbaum/copilot.lua' },

    -- Debugger
    { 'mfussenegger/nvim-dap' },
    { 'mfussenegger/nvim-dap-python' },
    { 'leoluz/nvim-dap-go' },
    { 'rcarriga/nvim-dap-ui' },
    { 'nvim-telescope/telescope-dap.nvim' },
    { 'theHamsta/nvim-dap-virtual-text' },
}

require('lazy').setup(lazy_plugins, {
    dev = {
        path = vim.env.HOME .. '/Desktop/personal-projects',
        patterns = { 'milanglacier' },
        fallback = true,
    },
    defaults = {
        lazy = true,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                'gzip',
                'matchit',
                'matchparen',
                'netrwPlugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
            },
        },
    },
})
