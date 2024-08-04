return {
    { 'hrsh7th/cmp-nvim-lsp' },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'milanglacier/minuet-ai.nvim' },
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
        },
        event = { 'InsertEnter', 'CmdLineEnter' },
        config = function()
            local cmp_formatting = function(entry, vim_item)
                local symbol_map = {
                    Number = '󰎠',
                    Array = '',
                    Variable = '',
                    Method = 'ƒ',
                    Property = '',
                    Boolean = '⊨',
                    Namespace = '',
                    Package = '',
                    Text = '󰉿',
                    Function = '󰊕',
                    Constructor = '',
                    Field = '󰜢',
                    Class = '󰠱',
                    Interface = '',
                    Module = '',
                    Unit = '󰑭',
                    Value = '󰎠',
                    Enum = '',
                    Keyword = '󰌋',
                    Snippet = '',
                    Color = '󰏘',
                    File = '󰈙',
                    Reference = '󰈇',
                    Folder = '󰉋',
                    EnumMember = '',
                    Constant = '󰏿',
                    Struct = '󰙅',
                    Event = '',
                    Operator = '󰆕',
                    TypeParameter = '',
                    Codeium = '󰩂',
                }

                local source_map = {
                    minuet = '󱗻',
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
                    codeium = '󰩂',
                }

                local symbol_fallback = ''
                local source_fallback = '󰜚'

                vim_item.kind = string.format('%s %s', symbol_map[vim_item.kind] or symbol_fallback, vim_item.kind)
                vim_item.menu = source_map[entry.source.name] or source_fallback

                return vim_item
            end

            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }

            local cmp = require 'cmp'
            local types = require 'cmp.types'
            local luasnip = require 'luasnip'

            Cmp_sources = {
                global = {
                    {
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        {
                            name = 'tags',
                            option = {
                                exact_match = true,
                                current_buffer_only = true,
                            },
                        },
                    },
                    {
                        { name = 'buffer' },
                        { name = 'path' },
                    },
                },
                quarto = {
                    {
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        { name = 'tags' },
                    },
                    {
                        { name = 'buffer' },
                        { name = 'path' },
                    },
                },
                r_rmd = {
                    {
                        { name = 'nvim_lsp' },
                        { name = 'luasnip' },
                        { name = 'tags' },
                    },
                    {
                        { name = 'buffer' },
                        { name = 'path' },
                    },
                },
            }

            require('minuet').setup {
                provider = 'gemini',
                request_timeout = 4,
                throttle = 2000,
                notify = 'warn',
                provider_options = {
                    codestral = {
                        optional = {
                            stop = { '\n\n' },
                            max_tokens = 256,
                        },
                    },
                    gemini = {
                        optional = {
                            generationConfig = {
                                maxOutputTokens = 256,
                                topP = 0.9,
                            },
                            safetySettings = {
                                {
                                    category = 'HARM_CATEGORY_DANGEROUS_CONTENT',
                                    threshold = 'BLOCK_NONE',
                                },
                                {
                                    category = 'HARM_CATEGORY_HATE_SPEECH',
                                    threshold = 'BLOCK_NONE',
                                },
                                {
                                    category = 'HARM_CATEGORY_HARASSMENT',
                                    threshold = 'BLOCK_NONE',
                                },
                                {
                                    category = 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
                                    threshold = 'BLOCK_NONE',
                                },
                            },
                        },
                    },
                    openai = {
                        optional = {
                            max_tokens = 256,
                            top_p = 0.9,
                        },
                    },
                },
            }

            local mappings = {
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
                ['<C-e>'] = cmp.mapping.abort(),
            }

            local cmdline_mappings = {
                ['<Tab>'] = {
                    c = function()
                        if cmp.visible() then
                            cmp.confirm { select = true }
                        else
                            cmp.complete()
                        end
                    end,
                },
                ['<S-Tab>'] = {
                    c = function()
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            cmp.complete()
                        end
                    end,
                },
                ['<C-n>'] = {
                    c = function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end,
                },
                ['<C-p>'] = {
                    c = function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end,
                },
                ['<C-e>'] = {
                    c = cmp.mapping.abort(),
                },
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
                mapping = mappings,
                window = {
                    completion = cmp.config.window.bordered(border_opts),
                    documentation = cmp.config.window.bordered(border_opts),
                },
                sources = cmp.config.sources(unpack(Cmp_sources.global)),
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
                mapping = cmdline_mappings,
                sources = {
                    { name = 'buffer' },
                },
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
                mapping = cmdline_mappings,
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
                sources = cmp.config.sources(unpack(Cmp_sources.quarto)),
            })

            cmp.setup.filetype({ 'r', 'rmd' }, {
                sources = cmp.config.sources(unpack(Cmp_sources.r_rmd)),
            })
        end,
    },
}
