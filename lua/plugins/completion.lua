local keymap = vim.api.nvim_set_keymap

local M = {
    {
        'milanglacier/minuet-ai.nvim',
        event = { 'InsertEnter' },
        cmd = { 'Minuet' },
        init = function()
            keymap('i', [[<A-z>z]], '<cmd>Minuet duet predict<CR>', {})
            keymap('i', [[<A-z>a]], '<cmd>Minuet duet apply<CR>', {})
            keymap('i', [[<A-z>x]], '<cmd>Minuet duet dismiss<CR>', {})
            keymap('n', [[<Leader>mz]], '<cmd>Minuet duet predict<CR>', {})
            keymap('n', [[<Leader>ma]], '<cmd>Minuet duet apply<CR>', {})
            keymap('n', [[<Leader>mx]], '<cmd>Minuet duet dismiss<CR>', {})
        end,
        config = function()
            require('minuet').setup {
                provider = 'openai_compatible',
                request_timeout = 2,
                throttle = 2000,
                virtualtext = {
                    auto_trigger_ft = {},
                    keymap = {
                        accept = '<A-A>',
                        accept_line = '<A-a>',
                        accept_n_lines = nil,
                        prev = '<A-;>',
                        next = "<A-'>",
                        dismiss = '<A-e>',
                    },
                    show_on_completion_menu = true,
                },
                notify = 'error',
                provider_options = {
                    codestral = {
                        optional = {
                            stop = { '\n\n' },
                            max_tokens = 256,
                        },
                    },
                    gemini = {
                        model = 'gemini-3.1-flash-lite-preview',
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
                        model = 'gpt-5.4-nano',
                        optional = {
                            max_completion_tokens = 128,
                            reasoning_effort = 'none',
                        },
                    },
                    openai_compatible = {
                        api_key = 'OPENCODE_API_KEY',
                        end_point = 'https://opencode.ai/zen/go/v1/chat/completions',
                        model = 'deepseek-v4-flash',
                        name = 'Opencode',
                        optional = {
                            -- reasoning_effort = 'none',
                            thinking = { type = 'disabled' },
                            max_tokens = 256,
                            top_p = 0.9,
                            -- provider = {
                            --     -- Prioritize throughput for faster completion
                            --     sort = 'throughput',
                            -- },
                        },
                    },
                },
                duet = {
                    provider = 'openai_compatible',
                    provider_options = {
                        gemini = {
                            model = 'gemini-3-flash-preview',
                            optional = {
                                generationConfig = {
                                    thinkingConfig = {
                                        thinkingLevel = 'minimal',
                                    },
                                },
                            },
                        },
                        openai_compatible = {
                            model = 'google/gemini-3.1-flash-lite-preview',
                            optional = {
                                reasoning_effort = 'none',
                            },
                        },
                    },
                },
            }

            -- Define Minuet completion keymaps prefixed with <A-c>, following
            -- my convention for manually invoked completions. This avoids
            -- issues with <A-'> and <A-;> being blocked by remote desktop
            -- applications on iOS.
            keymap('i', [[<A-c>']], '', {
                callback = function()
                    require('minuet.virtualtext').action.next()
                end,
                desc = 'Minuet next completion',
            })

            keymap('i', [[<A-c>;]], '', {
                callback = function()
                    require('minuet.virtualtext').action.prev()
                end,
                desc = 'Minuet previous completion',
            })
        end,
    },
    { 'quangnguyen30192/cmp-nvim-tags' },
    {
        'L3MON4D3/LuaSnip',
        config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip.loaders.from_vscode').lazy_load {
                paths = { vim.fn.stdpath 'config' .. '/snippets' },
            }
        end,
        dependencies = {
            { 'rafamadriz/friendly-snippets' },
        },
    },

    {
        import = 'plugins.completions.blink',
        cond = Milanglacier.completion_frontend == 'blink',
    },
    {
        import = 'plugins.completions.cmp',
        cond = Milanglacier.completion_frontend == 'cmp',
    },
    {
        -- This file contains configurations for both builtin and
        -- mini.completion as mini.completion is essentially a wrapper for
        -- builtin completion.
        import = 'plugins.completions.builtin',
        cond = Milanglacier.completion_frontend == 'builtin' or Milanglacier.completion_frontend == 'mini',
    },
}

M.kind_icons = {
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
    claude = '󰋦',
    openai = '󱢆',
    codestral = '󱎥',
    mistral = '󱎥',
    gemini = '',
    Groq = '',
    Openrouter = '󱂇',
    Ollama = '󰳆',
    ['Llama.cpp'] = '󰳆',
    Deepseek = '',
    -- FALLBACK
    fallback = '',
}

M.source_icons = {
    minuet = '󱗻',
    orgmode = '',
    otter = '󰼁',
    nvim_lsp = '',
    lsp = '',
    buffer = '',
    luasnip = '',
    snippets = '',
    path = '',
    git = '',
    tags = '',
    cmdline = '󰘳',
    latex_symbols = '',
    cmp_nvim_r = '󰟔',
    codeium = '󰩂',
    -- FALLBACK
    fallback = '󰜚',
}

return M
