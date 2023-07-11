local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

require('nvim-treesitter.configs').setup {
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = {
        'r',
        'python',
        'cpp',
        'lua',
        'vim',
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
        disable = { 'sql' },
        additional_vim_regex_highlighting = { 'org', 'latex', 'markdown' },
    },

    indent = {
        enable = true,
        disable = { 'python', 'org', 'tex', 'sql' },
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
keymap('n', '<leader>mr', [[<cmd>lua require('ssr').open()<cr>]], opts 'misc: treesitter structural replace')
keymap('v', '<leader>mr', [[<cmd>lua require('ssr').open()<cr>]], opts 'misc: treesitter structural replace')

require('treesitter-context').setup {
    enable = true,
    throttle = true,
}

vim.g.rainbow_delimiters = {
    query = {
        latex = 'rainbow-blocks',
    },
}

require 'rainbow-delimiters'

vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

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
        'markdown.pandoc',
        'lua',
        'query',
        'vim',
        'toml',
        'yaml',
    },
    group = my_augroup,
    desc = 'Use treesitter fold',
    command = 'setlocal foldmethod=expr',
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
