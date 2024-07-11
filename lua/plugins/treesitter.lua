local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local keymap = vim.api.nvim_set_keymap

local function list_filter(parent_list, excluded_list)
    return vim.tbl_filter(function(item)
        return not vim.tbl_contains(excluded_list, item)
    end, parent_list)
end

TS_Parsers = {
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
}

-- highlight
local disable_highlight = { 'sql', 'tex', 'latex', 'markdown_inline', 'regex', 'bash' }
TS_Parsers_Enabled_for_Highlight = list_filter(TS_Parsers, disable_highlight)
table.insert(TS_Parsers_Enabled_for_Highlight, 'quarto')
table.insert(TS_Parsers_Enabled_for_Highlight, 'rmd')

-- indent
local disable_indent = { 'python', 'sql', 'tex', 'latex', 'markdown_inline', 'regex', 'bash' }
TS_Parsers_Enabled_for_Indent = list_filter(TS_Parsers, disable_indent)

-- fold
TS_Parsers_Enabled_for_Fold = {
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
}

return {
    {
        'nvim-treesitter/nvim-treesitter',
        -- lazy load configs are copied from lazyvim/plugins/treesitter.lua
        -- NOTE: This is a simplifed version. If in future there are bugs happened,
        -- will consult to lazyvim.
        event = { 'VeryLazy', 'LazyFile' },
        build = ':TSUpdate',
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        branch = 'main',
        config = function()
            require('nvim-treesitter').setup {
                ensure_installed = TS_Parsers,
                auto_install = true,
            }

            vim.treesitter.language.register('markdown', { 'quarto', 'rmd' })

            autocmd('FileType', {
                pattern = TS_Parsers_Enabled_for_Highlight,
                group = my_augroup,
                desc = 'Enable treesitter highlight',
                callback = function()
                    vim.treesitter.start()
                end,
            })

            autocmd('FileType', {
                pattern = { 'quarto', 'rmd' },
                group = my_augroup,
                desc = 'Enable regex highlight with treesitter',
                callback = function()
                    vim.cmd [[setlocal syntax=on]]
                end,
            })

            autocmd('FileType', {
                pattern = TS_Parsers_Enabled_for_Indent,
                group = my_augroup,
                desc = 'Enable treesitter indent',
                callback = function()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            autocmd('FileType', {
                pattern = TS_Parsers_Enabled_for_Fold,
                group = my_augroup,
                desc = 'Use treesitter fold',
                command = 'setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
            })
        end,
    },

    {
        'HiPhish/rainbow-delimiters.nvim',
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

    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
    },
    {
        'romgrk/nvim-treesitter-context',
        event = { 'VeryLazy', 'LazyFile' },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        config = function()
            require('treesitter-context').setup {
                enable = true,
                throttle = true,
            }
        end,
    },

    {
        'mfussenegger/nvim-treehopper',
        init = function()
            keymap('v', '<CR>', ':<C-U>lua require("tsht").nodes()<CR>', {
                desc = 'treesitter nodes',
            })
            keymap('o', '<CR>', '', {
                callback = function()
                    require('tsht').nodes()
                end,
                desc = 'treesitter nodes',
            })
        end,
    },
}
