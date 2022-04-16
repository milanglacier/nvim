vim.cmd [[packadd! nvim-cmp]]
vim.cmd [[packadd! cmp-nvim-lsp]]
vim.cmd [[packadd! cmp-buffer]]
vim.cmd [[packadd! cmp-path]]
vim.cmd [[packadd! cmp-cmdline]]
vim.cmd [[packadd! cmp-nvim-lua]]
vim.cmd [[packadd! cmp-omni]]
vim.cmd [[packadd! cmp-latex-symbols]]
vim.cmd [[packadd! cmp_luasnip]]

vim.cmd [[packadd! lspkind-nvim]]

local cmp = require 'cmp'
local lspkind = require 'lspkind'

local my_mappings = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<A-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<tab>'] = cmp.mapping.confirm { select = true },
    ['<ESC>'] = cmp.mapping.abort(),
}

cmp.setup {
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = cmp.mapping.preset.insert(my_mappings),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'omni' },
        { name = 'luasnip' }, -- For luasnip users.
        { name = 'nvim_lua' },
    }, {
        { name = 'buffer' },
        { name = 'latex_symbols' },
    }),
    formatting = {
        format = lspkind.cmp_format {
            mode = 'symbol_text', -- show only symbol annotations
            maxwidth = 60, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        },
    },
}

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    }),
})

cmp.setup.filetype('sql', {
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline {
        ['<Tab>'] = { c = cmp.mapping.confirm { select = true } },
        ['<A-Space>'] = { c = cmp.mapping.complete() },
    },
    sources = {
        { name = 'buffer' },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline {
        ['<Tab>'] = { c = cmp.mapping.confirm { select = true } },
        ['<A-Space>'] = { c = cmp.mapping.complete() },
    },
    sources = cmp.config.sources({
        { name = 'path' },
    }, {
        { name = 'cmdline' },
    }),
})
