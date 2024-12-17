local completion_frontend = 'cmp'
local blink_use_main = true

local M = {
    {
        'milanglacier/minuet-ai.nvim',
        event = { 'InsertEnter' },
        config = function()
            require('minuet').setup {
                provider = 'gemini',
                request_timeout = 4,
                throttle = 2000,
                virtualtext = {
                    auto_trigger_ft = {},
                    keymap = {
                        accept = '<A-A>',
                        accept_line = '<A-a>',
                        prev = '<A-[>',
                        next = '<A-]>',
                        dismiss = '<A-e>',
                    },
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
                        api_key = 'FIREWORKS_API_KEY',
                        end_point = 'https://api.fireworks.ai/inference/v1/chat/completions',
                        model = 'accounts/fireworks/models/llama-v3p3-70b-instruct',
                        name = 'Fireworks',
                        optional = {
                            max_tokens = 256,
                            top_p = 0.9,
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
        enabled = function()
            return completion_frontend == 'blink'
        end,
    },
    {
        import = 'plugins.completions.cmp',
        enabled = function()
            return completion_frontend == 'cmp'
        end,
    },
}

M.completion_frontend = completion_frontend
M.blink_use_main = blink_use_main

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
    groq = '',
    -- FALLBACK
    fallback = '',
}

M.source_icons = {
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
    -- FALLBACK
    fallback = '󰜚',
}

return M
