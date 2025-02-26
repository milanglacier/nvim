local blink_use_main = Milanglacier.blink_use_main

local M = {
    {

        'saghen/blink.cmp',
        -- use tagged release when not use main
        version = not blink_use_main and '*' or nil,
        event = { 'InsertEnter', 'CmdlineEnter' },
        -- build from source when use main
        build = blink_use_main and 'cargo build --release' or nil,
        dependencies = {
            { 'L3MON4D3/LuaSnip' },
            { 'quangnguyen30192/cmp-nvim-tags' },
            {
                'saghen/blink.compat',
                version = not blink_use_main and '*' or nil,
                config = function()
                    require('blink.compat').setup {}
                end,
            },
        },
        config = function()
            local function accept_nth_items(n)
                return function(cmp)
                    cmp.accept { index = n }
                end
            end

            require('blink-cmp').setup {

                keymap = {
                    preset = 'super-tab',
                    ['<C-space>'] = {},
                    ['<C-e>'] = { 'cancel', 'fallback' },
                    ['<A-y>'] = {
                        function(cmp)
                            cmp.show { providers = { 'minuet' } }
                        end,
                    },
                    ['<A-1>'] = { accept_nth_items(1), 'fallback' },
                    ['<A-2>'] = { accept_nth_items(2), 'fallback' },
                    ['<A-3>'] = { accept_nth_items(3), 'fallback' },
                    ['<A-4>'] = { accept_nth_items(4), 'fallback' },
                    ['<A-5>'] = { accept_nth_items(5), 'fallback' },
                    ['<A-6>'] = { accept_nth_items(6), 'fallback' },
                    ['<A-7>'] = { accept_nth_items(7), 'fallback' },
                    ['<A-8>'] = { accept_nth_items(8), 'fallback' },
                    ['<A-9>'] = { accept_nth_items(9), 'fallback' },
                },

                completion = {
                    accept = {
                        auto_brackets = {
                            enabled = false,
                        },
                    },
                    list = {
                        selection = {
                            preselect = true,
                            auto_insert = true,
                        },
                    },
                    documentation = {
                        window = {
                            border = 'rounded',
                        },
                        auto_show = true,
                        auto_show_delay_ms = 200,
                    },
                    menu = {
                        border = 'rounded',
                        draw = {
                            treesitter = { 'lsp' },
                            columns = {
                                { 'label', 'label_description', gap = 1 },
                                { 'kind_icon', 'kind' },
                                { 'source_icon' },
                            },
                            components = {
                                source_icon = {
                                    -- don't truncate source_icon
                                    ellipsis = false,
                                    text = function(ctx)
                                        local source_icons = require('plugins.completion').source_icons
                                        return source_icons[ctx.source_name:lower()] or source_icons.fallback
                                    end,
                                    highlight = 'BlinkCmpSource',
                                },
                            },
                        },
                    },

                    trigger = { prefetch_on_insert = false },
                },

                snippets = { preset = 'luasnip' },

                cmdline = {
                    keymap = {
                        -- I want to use tab to confirm selection rather than
                        -- cycle between completion item
                        preset = 'super-tab',
                    },
                    completion = {
                        menu = {
                            auto_show = true,
                        },
                        -- disable ghost text as I don't use noice
                        ghost_text = { enabled = false },
                    },
                },

                sources = {
                    default = { 'lsp', 'path', 'snippets', 'buffer', 'tags' },
                    per_filetype = {
                        org = { 'lsp', 'path', 'snippets', 'buffer', 'orgmode', 'tags' },
                    },
                    min_keyword_length = 0,
                    providers = {
                        snippets = {
                            score_offset = 4,
                        },
                        tags = {
                            name = 'tags',
                            module = 'blink.compat.source',
                            score_offset = 1,
                            opts = {
                                exact_match = true,
                                current_buffer_only = true,
                            },
                        },
                        orgmode = {
                            name = 'orgmode',
                            module = 'blink.compat.source',
                            score_offset = 4,
                        },
                        minuet = {
                            name = 'minuet',
                            module = 'minuet.blink',
                            score_offset = 8,
                        },
                    },
                },

                appearance = {
                    use_nvim_cmp_as_default = true,
                    nerd_font_variant = 'normal',
                    kind_icons = require('plugins.completion').kind_icons,
                },

                -- we will disable blink completion in terminal mode, as
                -- completion should be handled by the terminal program itself.
                term = { enabled = false },
            }
        end,
    },
}

return M
