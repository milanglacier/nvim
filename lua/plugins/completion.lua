local gemini_prompt = [[
You are the backend of an AI-powered code completion engine. Your task is to
provide code suggestions based on the user's input. The user's code will be
enclosed in markers:

- `<contextAfterCursor>`: Code context after the cursor
- `<cursorPosition>`: Current cursor location
- `<contextBeforeCursor>`: Code context before the cursor
]]

local gemini_few_shots = {}

gemini_few_shots[1] = {
    role = 'user',
    content = [[
# language: python
<contextBeforeCursor>
def fibonacci(n):
    <cursorPosition>
<contextAfterCursor>

fib(5)]],
}

local gemini_chat_input_template =
    '{{{language}}}\n{{{tab}}}\n<contextBeforeCursor>\n{{{context_before_cursor}}}<cursorPosition>\n<contextAfterCursor>\n{{{context_after_cursor}}}'

local M = {
    {
        'milanglacier/minuet-ai.nvim',
        event = { 'InsertEnter' },
        config = function()
            gemini_few_shots[2] = require('minuet.config').default_few_shots[2]

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
                        system = {
                            prompt = gemini_prompt,
                        },
                        few_shots = gemini_few_shots,
                        chat_input = {
                            template = gemini_chat_input_template,
                        },
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
