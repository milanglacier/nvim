local blink_use_main = require('plugins.completion').blink_use_main

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
                    ['<A-i>'] = { 'show', 'show_documentation', 'hide_documentation' },
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
                        selection = 'auto_insert',
                    },
                    documentation = {
                        auto_show = true,
                        auto_show_delay_ms = 200,
                    },
                    menu = {
                        border = 'rounded',
                        draw = {
                            treesitter = { 'lsp' },
                            columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } },
                        },
                    },
                },

                snippets = {
                    expand = function(snippet)
                        require('luasnip').lsp_expand(snippet)
                    end,
                    active = function(filter)
                        if filter and filter.direction then
                            return require('luasnip').jumpable(filter.direction)
                        end
                        return require('luasnip').in_snippet()
                    end,
                    jump = function(direction)
                        require('luasnip').jump(direction)
                    end,
                },

                sources = {
                    default = { 'lsp', 'path', 'luasnip', 'buffer', 'tags' },
                    cmdline = {},
                    per_filetype = {
                        org = { 'lsp', 'path', 'snippets', 'buffer', 'orgmode', 'tags' },
                    },
                    min_keyword_length = 1,
                    providers = {
                        luasnip = {
                            score_offset = 2,
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
                    },
                },

                appearance = {
                    use_nvim_cmp_as_default = true,
                    nerd_font_variant = 'normal',
                    kind_icons = require('plugins.completion').kind_icons,
                },
            }
        end,
    },
}

return M
