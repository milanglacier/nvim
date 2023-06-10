local did_load_cmp = false
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

local function load_cmp_and_luasnip()
    require('luasnip.loaders.from_vscode').lazy_load()
    require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }

    local cmp = require 'cmp'
    local types = require 'cmp.types'
    local lspkind = require 'lspkind'
    local luasnip = require 'luasnip'

    local my_mappings = {
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<A-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm { select = true },
        ['<C-n>'] = cmp.mapping.select_next_item { behavior = types.cmp.SelectBehavior.Insert },
        ['<C-p>'] = cmp.mapping.select_prev_item { behavior = types.cmp.SelectBehavior.Insert },
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

    -- copied from AstroNvim
    local border_opts = {
        border = 'single',
        winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
    }

    cmp.setup {
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert(my_mappings),
        window = {
            completion = cmp.config.window.bordered(border_opts),
            documentation = cmp.config.window.bordered(border_opts),
        },
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            {
                name = 'tags',
                option = {
                    exact_match = true,
                    current_buffer_only = true,
                },
            },
        }, {
            { name = 'buffer' },
            { name = 'path' },
        }),
        formatting = {
            format = lspkind.cmp_format {
                mode = 'symbol_text',
                maxwidth = 60,
                menu = {
                    orgmode = '',
                    otter = '󰼁',
                    nvim_lsp = '',
                    buffer = '',
                    luasnip = '',
                    path = '',
                    git = '',
                    tags = '',
                    cmdline = '󰘳',
                    latex_symbols = '',
                    cmp_nvim_r = '󰟔',
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
            ['<Tab>'] = {
                c = function()
                    if cmp.visible() then
                        cmp.confirm { select = true }
                    else
                        cmp.complete()
                    end
                end,
            },
            ['<A-Space>'] = { c = cmp.mapping.complete() },
        },
        sources = {
            { name = 'buffer' },
        },
    })

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline {
            ['<Tab>'] = {
                c = function()
                    if cmp.visible() then
                        cmp.confirm { select = true }
                    else
                        cmp.complete()
                    end
                end,
            },
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

    cmp.setup.filetype('quarto', {
        sources = cmp.config.sources({
            { name = 'otter' },
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'tags' },
        }, {
            { name = 'buffer' },
            { name = 'path' },
        }),
    })

    cmp.setup.filetype({ 'r', 'rmd' }, {
        sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'tags' },
        }, {
            -- { name = 'cmp_nvim_r' },
            { name = 'buffer' },
            { name = 'path' },
        }),
    })
end

autocmd({ 'InsertEnter', 'CmdlineEnter' }, {
    group = my_augroup,
    desc = 'Load cmp',
    once = true,
    callback = function()
        if not did_load_cmp then
            load_cmp_and_luasnip()
            did_load_cmp = true
        end
    end,
})
