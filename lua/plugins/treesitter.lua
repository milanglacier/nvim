local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

return {
    {
        'nvim-treesitter/nvim-treesitter',
        -- lazy load configs are copied from lazyvim/plugins/treesitter.lua
        -- NOTE: This is a simplifed version. If in future there are bugs happened,
        -- will consult to lazyvim.
        event = { 'VeryLazy', 'LazyFile' },
        build = ':TSUpdate',
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        pin = '173515a5d2be6e98c2996189f77ee5993620e2aa',
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter-textobjects',
                pin = '34867c69838078df7d6919b130c0541c0b400c47',
            },
            {
                'romgrk/nvim-treesitter-context',
                pin = '1b9c756c0cad415f0a2661c858448189dd120c15',
                config = function()
                    require('treesitter-context').setup {
                        enable = true,
                        throttle = true,
                    }
                end,
            },
        },
        config = function()
            require('nvim-treesitter.configs').setup {
                -- One of "all", "maintained" (parsers with maintainers), or a list of languages
                ensure_installed = {
                    'r',
                    'python',
                    'cpp',
                    'lua',
                    'vim',
                    'vimdoc',
                    'yaml',
                    'toml',
                    'json',
                    'html',
                    'css',
                    'javascript',
                    'regex',
                    'latex',
                    'markdown',
                    'markdown_inline',
                    'go',
                    'sql',
                    'bash',
                },

                -- Install languages synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- List of parsers to ignore installing
                -- ignore_install = { "javascript" },

                highlight = {
                    enable = true,
                    disable = { 'sql', 'vimdoc' },
                    additional_vim_regex_highlighting = { 'latex' },
                },

                indent = {
                    enable = true,
                    disable = { 'python', 'tex', 'sql' },
                },

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = '<CR><CR>',
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
                            ['ak'] = '@class.outer',
                            ['ik'] = '@class.inner',
                            ['al'] = '@loop.outer',
                            ['il'] = '@loop.inner',
                            ['ac'] = '@conditional.outer',
                            ['ic'] = '@conditional.inner',
                            ['ie'] = '@call.inner',
                            ['ae'] = '@call.outer',
                            ['a<Leader>a'] = '@parameter.outer',
                            ['i<Leader>a'] = '@parameter.inner',
                            -- latex textobjects
                            ['a<Leader>lf'] = '@frame.outer',
                            ['a<Leader>ls'] = '@statement.outer',
                            ['a<Leader>lb'] = '@block.outer',
                            ['a<Leader>lc'] = '@class.outer',
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            [']f'] = '@function.outer',
                            [']<Leader>c'] = '@class.outer',
                            [']k'] = '@class.outer',
                            [']l'] = '@loop.outer',
                            [']c'] = '@conditional.outer',
                            [']e'] = '@call.outer',
                            [']a'] = '@parameter.outer',
                            -- latex motions
                            [']<Leader>lf'] = '@frame.outer',
                            [']<Leader>ls'] = '@statement.outer',
                            [']<Leader>lb'] = '@block.outer',
                            [']<Leader>lc'] = '@class.outer',
                        },
                        goto_next_end = {
                            [']F'] = '@function.outer',
                            [']<Leader>C'] = '@class.outer',
                            [']K'] = '@class.outer',
                            [']L'] = '@loop.outer',
                            [']C'] = '@conditional.outer',
                            [']E'] = '@call.outer',
                            [']A'] = '@parameter.outer',
                            -- latex motions
                            [']<Leader>lF'] = '@frame.outer',
                            [']<Leader>lS'] = '@statement.outer',
                            [']<Leader>lB'] = '@block.outer',
                            [']<Leader>lC'] = '@class.outer',
                        },
                        goto_previous_start = {
                            ['[f'] = '@function.outer',
                            ['[<Leader>c'] = '@class.outer',
                            ['[k'] = '@class.outer',
                            ['[l'] = '@loop.outer',
                            ['[c'] = '@conditional.outer',
                            ['[e'] = '@call.outer',
                            ['[a'] = '@parameter.outer',
                            -- latex motions
                            ['[<Leader>lf'] = '@frame.outer',
                            ['[<Leader>ls'] = '@statement.outer',
                            ['[<Leader>lb'] = '@block.outer',
                            ['[<Leader>lc'] = '@class.outer',
                        },
                        goto_previous_end = {
                            ['[F'] = '@function.outer',
                            ['[<Leader>C'] = '@class.outer',
                            ['[K'] = '@class.outer',
                            ['[L'] = '@loop.outer',
                            ['[C'] = '@conditional.outer',
                            ['[E'] = '@call.outer',
                            ['[A'] = '@parameter.outer',
                            -- latex motions
                            ['[<Leader>lF'] = '@frame.outer',
                            ['[<Leader>lS'] = '@statement.outer',
                            ['[<Leader>lB'] = '@block.outer',
                            ['[<Leader>lC'] = '@class.outer',
                        },
                    },
                },

                matchup = {
                    enable = true, -- mandatory, false will disable the whole extension
                    disable_virtual_text = true,
                    -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
                },
            }

            autocmd('FileType', {
                pattern = {
                    'python',
                    'c',
                    'cpp',
                    'go',
                    'html',
                    'javascript',
                    'json',
                    'tex',
                    'markdown',
                    'lua',
                    'query',
                    'vim',
                    'toml',
                    'yaml',
                },
                group = my_augroup,
                desc = 'Use treesitter fold',
                command = 'setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
            })
        end,
    },

    {
        'HiPhish/rainbow-delimiters.nvim',
        pin = '5c9660801ce345cd3835e1947c12b54290ab7e71',
        event = 'LazyFile',
        config = function()
            vim.g.rainbow_delimiters = {
                query = {
                    latex = 'rainbow-blocks',
                },
            }

            require 'rainbow-delimiters'
        end,
    },
}
