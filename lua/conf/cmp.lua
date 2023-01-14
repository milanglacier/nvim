vim.cmd.packadd { 'nvim-cmp', bang = true }
vim.cmd.packadd { 'cmp-nvim-lsp', bang = true }
vim.cmd.packadd { 'cmp-buffer', bang = true }
vim.cmd.packadd { 'cmp-path', bang = true }
vim.cmd.packadd { 'cmp-cmdline', bang = true }
vim.cmd.packadd { 'cmp-nvim-lua', bang = true }
vim.cmd.packadd { 'cmp-latex-symbols', bang = true }
vim.cmd.packadd { 'cmp_luasnip', bang = true }
vim.cmd.packadd { 'cmp-nvim-tags', bang = true }
vim.cmd.packadd { 'cmp-git', bang = true }

vim.cmd.packadd { 'lspkind-nvim', bang = true }

local cmp = require 'cmp'
local lspkind = require 'lspkind'
local luasnip = require 'luasnip'

local my_mappings = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<A-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.confirm { select = true }
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            fallback()
        end
    end),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end),
    ['<ESC>'] = cmp.mapping.abort(),
}

cmp.setup {
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert(my_mappings),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'tags' },
    }, {
        { name = 'buffer' },
        { name = 'path' },
        { name = 'latex_symbols' },
    }),
    formatting = {
        format = lspkind.cmp_format {
            mode = 'symbol_text',
            maxwidth = 60,
            menu = {
                nvim_lsp = '',
                buffer = '﬘',
                luasnip = '',
                path = '',
                git = '',
                tags = '',
                cmdline = 'גּ',
                latex_symbols = '',
            },
        },
    },
    completion = { keyword_length = 2 },
}

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' },
    }, {
        { name = 'buffer' },
    }),
})
require('cmp_git').setup()

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

cmp.setup.filetype('org', {
    sources = cmp.config.sources({
        { name = 'orgmode' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
        { name = 'tags' },
    }),
})
