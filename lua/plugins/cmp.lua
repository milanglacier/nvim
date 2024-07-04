local sources = require('conf.cmp').sources

return {
    { 'hrsh7th/cmp-nvim-lsp' },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-cmdline' },
            {
                'L3MON4D3/LuaSnip',
                dependencies = {
                    { 'rafamadriz/friendly-snippets' },
                },
            },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'quangnguyen30192/cmp-nvim-tags' },
            { 'petertriho/cmp-git' },
            -- { 'jalvesaq/cmp-nvim-r' },
        },
        event = { 'InsertEnter', 'CmdLineEnter' },
        config = function()
            local cmp_formatting = function(entry, vim_item)
                local symbol_map = {
                    Number = '[i]',
                    Array = '[A]',
                    Variable = '[V]',
                    Method = '[m]',
                    Property = '[p]',
                    Boolean = '[B]',
                    Namespace = '[N]',
                    Package = '[P]',
                    Text = '[s]',
                    Function = '[f]',
                    Constructor = '[C]',
                    Field = '[a]',
                    Class = '[C]',
                    Interface = '[I]',
                    Module = '[M]',
                    Unit = '[U]',
                    Value = '[i]',
                    Enum = '[E]',
                    Keyword = '[K]',
                    Snippet = '[S]',
                    Color = '[H]',
                    File = '[F]',
                    Reference = '[r]',
                    Folder = '[D]',
                    EnumMember = '[E]',
                    Constant = '[π]',
                    Struct = '[C]',
                    Event = '[e]',
                    Operator = '[O]',
                    TypeParameter = '[T]',
                    Codeium = '[A]',
                }

                local source_map = {
                    minuet = '<M>',
                    orgmode = '<O>',
                    otter = '<o>',
                    nvim_lsp = '<L>',
                    buffer = '<b>',
                    luasnip = '<S>',
                    path = '<f>',
                    git = '<G>',
                    tags = '<T>',
                    cmdline = '<t>',
                    latex_symbols = '<l>',
                    cmp_nvim_r = '<R>',
                    codeium = '<A>',
                }

                local symbol_fallback = '[*]'
                local source_fallback = '[^]'

                vim_item.kind = string.format('%s %s', symbol_map[vim_item.kind] or symbol_fallback, vim_item.kind)
                vim_item.menu = source_map[entry.source.name] or source_fallback

                return vim_item
            end

            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }

            local cmp = require 'cmp'
            local types = require 'cmp.types'
            local luasnip = require 'luasnip'

            require('minuet').setup {}

            local my_mappings = {
                ['<A-y>'] = require('minuet').make_cmp_map(),
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<A-i>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping.confirm { select = true },
                -- Select the candidates in nvim-cmp window and also insert the text into the buffer
                ['<C-n>'] = cmp.mapping.select_next_item { behavior = types.cmp.SelectBehavior.Insert },
                ['<C-p>'] = cmp.mapping.select_prev_item { behavior = types.cmp.SelectBehavior.Insert },
                -- Select the candidates in nvim-cmp window but don't insert the text into the buffer
                ['<C-j>'] = cmp.mapping.select_next_item { behavior = types.cmp.SelectBehavior.Select },
                ['<C-k>'] = cmp.mapping.select_prev_item { behavior = types.cmp.SelectBehavior.Select },
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
                sources = cmp.config.sources(unpack(sources.global)),
                formatting = {
                    format = cmp_formatting,
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
                    ['<A-i>'] = { c = cmp.mapping.complete() },
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
                    ['<A-i>'] = { c = cmp.mapping.complete() },
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
                sources = cmp.config.sources(unpack(sources.quarto)),
            })

            cmp.setup.filetype({ 'r', 'rmd' }, {
                sources = cmp.config.sources(unpack(sources.r_rmd)),
            })
        end,
    },
}
