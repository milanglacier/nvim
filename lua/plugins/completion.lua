local M = {
    {
        'milanglacier/minuet-ai.nvim',
        event = { 'InsertEnter' },
        config = function()
            require('minuet').setup {
                provider = 'gemini',
                request_timeout = 2,
                throttle = 2000,
                virtualtext = {
                    auto_trigger_ft = {},
                    keymap = {
                        accept = '<A-A>',
                        accept_line = '<A-a>',
                        accept_n_lines = '<A-z>',
                        prev = "<A-'>",
                        next = '<A-;>',
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
                    openai_compatible = {
                        api_key = 'OPENROUTER_API_KEY',
                        end_point = 'https://openrouter.ai/api/v1/chat/completions',
                        model = 'meta-llama/llama-3.3-70b-instruct',
                        name = 'Openrouter',
                        optional = {
                            max_tokens = 128,
                            top_p = 0.9,
                            provider = {
                                -- Prioritize throughput for faster completion
                                sort = 'throughput',
                            },
                        },
                    },
                },
            }
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
