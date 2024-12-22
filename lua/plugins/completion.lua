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
        cond = Milanglacier.completion_frontend == 'blink',
    },
    {
        import = 'plugins.completions.cmp',
        cond = Milanglacier.completion_frontend == 'cmp',
    },
}

M.kind_icons = {
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
    claude = '',
    openai = '',
    codestral = '',
    mistral = '',
    gemini = '',
    groq = '',
    fallback = '[-]',
}

M.source_icons = {
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

return M
