
lua <<EOF
require'nvim-treesitter.configs'.setup {
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = {"python", "r", "latex", "julia", "bash", "vim", "lua"},

    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- List of parsers to ignore installing
    -- ignore_install = { "javascript" },


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
            keymaps  = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["aC"] = "@class.outer",
                ["iC"] = "@class.inner",
                ["aL"] = "@loop.outer",
                ["iL"] = "@loop.inner",
                ["ac"] = "@conditional.outer",
                ["ic"] = "@conditional.inner",
                ["i<Leader>e"] = "@call.inner",
                ["a<Leader>e"] = "@call.outer",
                
            }
        },
        move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
               ["]f"] = "@function.outer",
               ["]<Leader>c"] = "@class.outer",
               ["]l"] = "@loop.outer",
               ["]c"] = "@conditional.outer",
               ["]<Leader>e"] = "@call.outer",
            },
            
            goto_next_end = {
                ["]F"] = "@function.outer",
                ["]<Leader>C"] = "@class.outer",
                ["]L"] = "@loop.outer",
                ["]C"] = "@conditional.outer",
                ["]<Leader>E"] = "@call.outer",
            },

            goto_previous_start = {
               ["[f"] = "@function.outer",
               ["[<Leader>c"] = "@class.outer",
               ["[l"] = "@loop.outer",
               ["[c"] = "@conditional.outer",
               ["[<Leader>e"] = "@call.outer",
            },

            goto_previous_end = {

               ["[F"] = "@function.outer",
               ["[<Leader>C"] = "@class.outer",
               ["[L"] = "@loop.outer",
               ["[C"] = "@conditional.outer",
               ["[<Leader>E"] = "@call.outer",
            }
        }
    }
}
EOF
