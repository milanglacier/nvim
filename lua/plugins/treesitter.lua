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

local disable_textobj = { 'sql', 'tex', 'latex', 'markdown_inline', 'regex', 'bash', 'vimdoc' }
TS_Parsers_Enabled_for_Text_Objs = list_filter(TS_Parsers, disable_textobj)

return {
    {
        'nvim-treesitter/nvim-treesitter',
        -- lazy load configs are copied from lazyvim/plugins/treesitter.lua
        -- NOTE: This is a simplifed version. If in future there are bugs happened,
        -- will consult to lazyvim.
        event = { 'LazyFile' },
        cmd = { 'TSUpdate', 'TSInstall' },
        build = ':TSUpdate',
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        branch = 'main',
        config = function()
            if vim.fn.executable 'tree-sitter' == 0 then
                vim.cmd [[MasonInstall tree-sitter-cli]]
            end

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
                command = 'setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()',
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
        event = { 'LazyFile' },
        lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
        branch = 'main',
        config = function()
            require('nvim-treesitter-textobjects').setup {
                select = {
                    -- Automatically jump forward to textobj, similar to targets.vim
                    lookahead = true,
                    include_surrounding_whitespace = false,
                },
                move = {
                    -- whether to set jumps in the jumplist
                    set_jumps = true,
                },
            }

            local selectors = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ak'] = '@class.outer',
                ['ik'] = '@class.inner',
                ['al'] = '@loop.outer',
                ['il'] = '@loop.inner',
                ['ac'] = '@conditional.outer',
                ['ic'] = '@conditional.inner',
                ['ie'] = '@call.inner',
                ['ae'] = '@call.outer',
                ['aA'] = '@parameter.outer', -- mini.ai's regex based argument (`a`) one works better
                ['iA'] = '@parameter.inner',
            }

            -- NOTE: The main branch of `nvim-treesitter-textobjects` currently
            -- contains bug affecting move commands. Await upstream fix to make
            -- them functional.
            -- local movers = {
            --     ['f'] = '@function.outer',
            --     ['k'] = '@class.outer',
            --     ['l'] = '@loop.outer',
            --     ['c'] = '@conditional.outer',
            -- }

            autocmd('FileType', {
                pattern = TS_Parsers_Enabled_for_Text_Objs,
                group = my_augroup,
                desc = 'Enable treesitter textobjects',
                callback = function()
                    for k, obj in pairs(selectors) do
                        vim.keymap.set({ 'x', 'o' }, k, function()
                            require('nvim-treesitter-textobjects.select').select_textobject(obj, 'textobjects')
                        end, {
                            desc = obj,
                            buffer = true,
                        })
                    end

                    -- for k, obj in pairs(movers) do
                    -- vim.keymap.set({ 'n', 'x', 'o' }, ']' .. k, function()
                    --     require('nvim-treesitter-textobjects.move').goto_next_start(obj, 'textobjects')
                    -- end, {
                    --     desc = obj .. ' next start',
                    --     buffer = true,
                    -- })
                    --
                    -- vim.keymap.set({ 'n', 'x', 'o' }, '[' .. k, function()
                    --     require('nvim-treesitter-textobjects.move').goto_previous_start(obj, 'textobjects')
                    -- end, {
                    --     desc = obj .. ' prev start',
                    --     buffer = true,
                    -- })
                    --
                    -- vim.keymap.set({ 'n', 'x', 'o' }, ']' .. k:upper(), function()
                    --     require('nvim-treesitter-textobjects.move').goto_next_end(obj, 'textobjects')
                    -- end, {
                    --     desc = obj .. ' next End',
                    --     buffer = true,
                    -- })
                    --
                    -- vim.keymap.set({ 'n', 'x', 'o' }, '[' .. k:upper(), function()
                    --     require('nvim-treesitter-textobjects.move').goto_previous_end(obj, 'textobjects')
                    -- end, {
                    --     desc = obj .. ' prev End',
                    --     buffer = true,
                    -- })
                    -- end
                end,
            })
        end,
    },
    {
        'romgrk/nvim-treesitter-context',
        event = { 'LazyFile' },
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
