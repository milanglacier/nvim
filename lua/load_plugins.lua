local max_jobs = nil
-- if #list_uis() == 0, then nvim runs in headless mode,
-- there's a packer bug:
-- in headless mode, max_jobs must be nil,
-- in TUI mode, max_jobs shouldn't be too large
if #vim.api.nvim_list_uis() > 0 then
    max_jobs = 10
end

require('packer').init {
    compile_on_sync = false,
    max_jobs = max_jobs,
}

require('packer').startup(function(use)
    -- optimize startup
    use { 'lewis6991/impatient.nvim' }
    use { 'wbthomason/packer.nvim' }

    -- colorschemes
    use { 'EdenEast/nightfox.nvim', opt = true }
    use { 'rose-pine/neovim', as = 'rose-pine', opt = true }
    use { 'folke/tokyonight.nvim', branch = 'main', opt = true }
    use { 'sainnhe/everforest', opt = true }
    use { 'sainnhe/edge', opt = true }
    use { 'ellisonleao/gruvbox.nvim', opt = true }
    use { 'rebelot/kanagawa.nvim', opt = true }
    use { 'catppuccin/nvim', as = 'catppuccin', opt = true }
    use { 'marko-cerovac/material.nvim', opt = true }
    use { 'ishan9299/nvim-solarized-lua', opt = true }

    -- Fix bugs and Utilities
    use { 'antoinemadec/FixCursorHold.nvim' }
    use { 'ahmedkhalf/project.nvim', opt = true }
    use { 'kyazdani42/nvim-tree.lua', opt = true } -- file explorer
    use { 'milanglacier/smartim', opt = true } -- automatically switch input method when switch mode
    use { 'sindrets/winshift.nvim', opt = true }
    use {
        'glacambre/firenvim',
        opt = true,
        run = function()
            vim.fn['firenvim#install'](0)
        end,
    }
    -- very simple, naive completion without LSP
    -- 'skywind3000/vim-auto-popmenu'
    -- 'skywind3000/vim-dict'

    -- UI
    use { 'nvim-lualine/lualine.nvim', opt = true }
    use { 'rcarriga/nvim-notify', opt = true }
    use { 'echasnovski/mini.nvim', opt = true }
    use { 'folke/trouble.nvim', opt = true }
    use { 'folke/which-key.nvim', opt = true }
    use { 'kyazdani42/nvim-web-devicons', opt = true }

    -- text-editing, motions, jumps tools
    use { 'justinmk/vim-sneak' }
    use { 'tpope/vim-surround', opt = true }
    use { 'numToStr/Comment.nvim', opt = true }
    use { 'tpope/vim-repeat' }
    use { 'michaeljsmith/vim-indent-object' }
    use { 'wellle/targets.vim', opt = true }
    use { 'AndrewRadev/dsf.vim' }
    use { 'gbprod/substitute.nvim' }
    use { 'andymass/vim-matchup' }
    use { 'tommcdo/vim-exchange' }
    use { 'kana/vim-textobj-user' }
    use { 'D4KU/vim-textobj-chainmember', opt = true }
    use { 'thinca/vim-textobj-between', opt = true }

    -- text editing tools only for nvim
    use { 'norcalli/nvim-colorizer.lua', opt = true }
    use { 'windwp/nvim-autopairs', opt = true }

    -- Tree sitter for enhanced text obj and syntax capturality
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            require('nvim-treesitter.install').update { sync = true }
        end,
    }
    use { 'nvim-treesitter/nvim-treesitter-textobjects', opt = true }
    use { 'p00f/nvim-ts-rainbow', opt = true }
    use { 'mfussenegger/nvim-treehopper', opt = true }
    use { 'mizlan/iswap.nvim', opt = true }
    use { 'romgrk/nvim-treesitter-context', opt = true }
    use { 'JoosepAlviste/nvim-ts-context-commentstring', opt = true }

    -- Set markdown/rmd syntax highlighting
    use { 'vim-pandoc/vim-pandoc-syntax', opt = true }
    use { 'vim-pandoc/vim-rmarkdown', branch = 'official-filetype', opt = true }

    -- Fuzzy finder for file search
    use { 'nvim-lua/plenary.nvim' }
    use { 'nvim-telescope/telescope.nvim', opt = true }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', opt = true }
    use { 'nvim-telescope/telescope-ui-select.nvim', opt = true }

    -- LSP config
    use { 'neovim/nvim-lspconfig', opt = true }

    -- lsp related tools, including lsp symbols, symbol outline, etc.
    use { 'glepnir/lspsaga.nvim', opt = true }
    use { 'stevearc/aerial.nvim', opt = true }
    use { 'onsails/lspkind-nvim', opt = true }
    use { 'ray-x/lsp_signature.nvim', opt = true }
    use { 'jose-elias-alvarez/null-ls.nvim', opt = true }
    use { 'ThePrimeagen/refactoring.nvim', opt = true }
    use { 'SmiteshP/nvim-navic', opt = true }

    -- Completion
    use { 'hrsh7th/cmp-nvim-lsp', opt = true }
    use { 'hrsh7th/cmp-buffer', opt = true }
    use { 'hrsh7th/cmp-path', opt = true }
    use { 'hrsh7th/cmp-cmdline', opt = true }
    use { 'hrsh7th/nvim-cmp', opt = true }
    use { 'hrsh7th/cmp-nvim-lua', opt = true }
    use { 'kdheepak/cmp-latex-symbols', opt = true }
    use { 'L3MON4D3/LuaSnip', opt = true }
    use { 'saadparwaiz1/cmp_luasnip', opt = true }
    use { 'quangnguyen30192/cmp-nvim-tags', opt = true }
    use { 'petertriho/cmp-git', opt = true }
    use { 'rafamadriz/friendly-snippets', opt = true }

    -- language development
    use { 'folke/neodev.nvim', opt = true }
    use { 'nanotee/sqls.nvim', opt = true }

    -- CLI tools

    -- REPL
    use { 'jalvesaq/Nvim-R', opt = true }
    use { 'hkupty/iron.nvim', opt = true }
    use { 'akinsho/toggleterm.nvim', opt = true }

    -- Git
    use { 'lewis6991/gitsigns.nvim', opt = true }
    use { 'TimUntersberger/neogit', opt = true }
    use { 'sindrets/diffview.nvim', opt = true }

    -- Other cli tools, ripgrep, hover, markdown, etc
    use { 'nvim-pack/nvim-spectre', opt = true }
    use { 'JASONews/glow-hover', opt = true }
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', opt = true }
    use { 'ludovicchabant/vim-gutentags', opt = true }
    use { 'nvim-orgmode/orgmode', opt = true }
    use { 'lervag/vimtex', opt = true }

    -- Debugger
    use { 'mfussenegger/nvim-dap', opt = true }
    use { 'mfussenegger/nvim-dap-python', opt = true }
    use { 'rcarriga/nvim-dap-ui', opt = true }
    use { 'nvim-telescope/telescope-dap.nvim', opt = true }
    use { 'theHamsta/nvim-dap-virtual-text', opt = true }

    if PACKER_BOOTSTRAP_SUCCESS then
        require('packer').sync()
    end
end)
