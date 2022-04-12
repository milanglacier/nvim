require('nvim-treesitter.configs').setup {
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = { 'r', 'python', 'cpp', 'lua', 'vim', 'julia', 'yaml', 'toml', 'json', 'html', 'css', 'javascript' },

    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- List of parsers to ignore installing
    -- ignore_install = { "javascript" },

    highlight = {
        -- `false` will disable the whole extension
        enable = not vim.g.vscode,

        -- list of language that will be disabled
        -- disable = { "c", "rust" },

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },

    rainbow = {
        enable = not vim.g.vscode,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
    },

    indent = {

        enable = true,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>',
        },
    },

    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',

                ['aC'] = '@class.outer',
                ['iC'] = '@class.inner',
                ['a<leader>c'] = '@class.outer',
                ['i<leader>c'] = '@class.inner',

                ['al'] = '@loop.outer',
                ['il'] = '@loop.inner',

                ['ac'] = '@conditional.outer',
                ['ic'] = '@conditional.inner',
                ['ie'] = '@call.inner',
                ['ae'] = '@call.outer',
                ['a<Leader>a'] = '@parameter.outer',
                ['i<Leader>a'] = '@parameter.inner',
                -- latex textobjects
                ['<LocalLeader>f'] = '@frame.outer',
                ['<LocalLeader>s'] = '@statement.outer',
                ['<LocalLeader>b'] = '@block.outer',
                ['<localLeader>c'] = '@class.outer',
            },
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
                [']f'] = '@function.outer',
                [']<Leader>c'] = '@class.outer',
                [']l'] = '@loop.outer',
                [']c'] = '@conditional.outer',
                [']e'] = '@call.outer',
                [']a'] = '@parameter.outer',
            },

            goto_next_end = {
                [']F'] = '@function.outer',
                [']<Leader>C'] = '@class.outer',
                [']L'] = '@loop.outer',
                [']C'] = '@conditional.outer',
                [']E'] = '@call.outer',
                [']A'] = '@parameter.outer',
            },

            goto_previous_start = {
                ['[f'] = '@function.outer',
                ['[<Leader>c'] = '@class.outer',
                ['[l'] = '@loop.outer',
                ['[c'] = '@conditional.outer',
                ['[e'] = '@call.outer',
                ['[a'] = '@parameter.outer',
            },

            goto_previous_end = {

                ['[F'] = '@function.outer',
                ['[<Leader>C'] = '@class.outer',
                ['[L'] = '@loop.outer',
                ['[C'] = '@conditional.outer',
                ['[E'] = '@call.outer',
                ['[A'] = '@parameter.outer',
            },
        },
    },

    matchup = {
        enable = true, -- mandatory, false will disable the whole extension
        disable_virtual_text = true,
        -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
    },
}

if not vim.g.vscode then
    vim.cmd [[packadd! nvim-treehopper]]
    vim.cmd [[packadd! nvim-treesitter-context]]
    vim.cmd [[packadd! iswap.nvim]]
    local keymap = vim.api.nvim_set_keymap
    keymap('o', '<leader>T', ":<C-U>lua require('tsht').nodes()<CR>", { silent = true })
    keymap('v', '<leader>T', ":<C-U>lua require('tsht').nodes()<CR>", { noremap = true, silent = true })
    keymap('n', '<leader>sw', '<cmd>ISwap<cr>', { noremap = true, silent = true })
    keymap('n', '<leader>sW', '<cmd>ISwapWith<cr>', { noremap = true, silent = true })

    require('treesitter-context').setup {
        enable = false,
        throttle = true,
    }
end
