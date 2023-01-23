vim.cmd.packadd { 'nvim-treesitter-textobjects', bang = true }
vim.cmd.packadd { 'nvim-ts-rainbow', bang = true }
vim.cmd.packadd { 'nvim-ts-context-commentstring', bang = true }

local keymap = vim.api.nvim_set_keymap

require('nvim-treesitter.configs').setup {
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = {
        'r',
        'python',
        'cpp',
        'lua',
        'vim',
        'julia',
        'yaml',
        'toml',
        'json',
        'html',
        'css',
        'javascript',
        'regex',
        'latex',
        'org',
        'markdown',
    },

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
        additional_vim_regex_highlighting = { 'org', 'latex', 'markdown' },
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
        disable = { 'python', 'org', 'tex' },
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
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
}

if not vim.g.vscode then
    vim.cmd.packadd { 'nvim-treehopper', bang = true }
    vim.cmd.packadd { 'nvim-treesitter-context', bang = true }
    vim.cmd.packadd { 'iswap.nvim', bang = true }

    local opts = function(desc)
        return {
            silent = true,
            noremap = true,
            desc = desc,
        }
    end

    keymap('o', '<leader>T', ":<C-U>lua require('tsht').nodes()<CR>", opts 'treesitter nodes')
    keymap('v', '<leader>T', ":<C-U>lua require('tsht').nodes()<CR>", opts 'treesitter nodes')
    keymap('n', '<leader>ms', '<cmd>ISwap<cr>', opts 'misc: treesitter swap')
    keymap('n', '<leader>mS', '<cmd>ISwapWith<cr>', opts 'misc: treesitter swapwith')

    require('treesitter-context').setup {
        enable = true,
        throttle = true,
    }
end

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

autocmd('FileType', {
    pattern = { 'rmd' },
    group = my_augroup,
    desc = 'disable treesitter highlight',
    callback = function()
        vim.defer_fn(function()
            vim.cmd 'TSBufDisable highlight'
            -- this is an embarassing hack
            -- currently nvimr will issue errors
            -- when pandoc-syntax highlight and treesitter parser for markdown
            -- is simultaneously enabled.
            -- The strategy is don't enable pandoc-syntax at the start
            -- until nvimr is successfully loaded,
            -- then disable treesitter's highlight.
        end, 300)
    end,
})

local emmykeymap = require('conf.builtin_extend').emmykeymap

emmykeymap('n', '(ts-incre-selection-init)', '<CR><CR>')
emmykeymap('n', '(ts-incre-selection-scope-incre)', '<CR>')
emmykeymap('n', '(ts-incre-selection-node-incre)', '<Tab>')
emmykeymap('n', '(ts-incre-selection-node-decre)', '<S-Tab>')

emmykeymap('x', '(ts-textobj-function-outer)', 'af')
emmykeymap('x', '(ts-textobj-class-outer)', 'ak')
emmykeymap('x', '(ts-textobj-class-outer-alias)', 'aC')
emmykeymap('x', '(ts-textobj-conditional-outer)', 'ac')
emmykeymap('x', '(ts-textobj-loop-outer)', 'al')
emmykeymap('x', '(ts-textobj-argument-outer)', 'a<Leader>a')
emmykeymap('x', '(ts-textobj-call-outer)', 'ae')
emmykeymap('x', '(ts-textobj-expression-outer)', 'ae')

emmykeymap('x', '(ts-textobj-tex-frame-outer)', 'a<Leader>lf')
emmykeymap('x', '(ts-textobj-tex-block-outer)', 'a<Leader>lb')
emmykeymap('x', '(ts-textobj-tex-statement-outer)', 'a<Leader>ls')
emmykeymap('x', '(ts-textobj-tex-class-outer)', 'a<Leader>lc')

emmykeymap('n', '(ts-motion-class-prev-start)', '[k')
emmykeymap('n', '(ts-motion-class-prev-end)', '[K')

emmykeymap('n', '(ts-motion-class-prev-start-alias)', '[<Leader>c')
emmykeymap('n', '(ts-motion-class-prev-end-alias)', '[<Leader>C')

emmykeymap('n', '(ts-motion-conditional-prev-start)', '[c')
emmykeymap('n', '(ts-motion-conditional-prev-end)', '[C')

emmykeymap('n', '(ts-motion-argument-prev-start)', '[a')
emmykeymap('n', '(ts-motion-argument-prev-end)', '[A')

emmykeymap('n', '(ts-motion-tex-block-prev-start)', '[<Leader>lb')
emmykeymap('n', '(ts-motion-tex-block-prev-end)', '[<Leader>lB')
emmykeymap('n', '(ts-motion-tex-class-prev-start)', '[<Leader>lc')
emmykeymap('n', '(ts-motion-tex-class-prev-end)', '[<Leader>lC')
emmykeymap('n', '(ts-motion-tex-statement-prev-start)', '[<Leader>ls')
emmykeymap('n', '(ts-motion-tex-statement-prev-end)', '[<Leader>lS')
emmykeymap('n', '(ts-motion-tex-frame-prev-start)', '[<Leader>lf')
emmykeymap('n', '(ts-motion-tex-frame-prev-end)', '[<Leader>lF')

emmykeymap('x', '(ts-select-node-with-label)', '<Leader>T')
emmykeymap('n', '(ts-swap-arguments)', '<Leader>sw')
emmykeymap('n', '(ts-swap-current-arguments-with)', '<Leader>sW')
