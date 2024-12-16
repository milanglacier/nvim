local opts = function(options)
    return {
        noremap = true,
        silent = true,
        desc = options[1] or options.desc,
        callback = options[2] or options.callback,
    }
end

local bufmap = vim.api.nvim_buf_set_keymap
local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local bufcmd = vim.api.nvim_buf_create_user_command
local command = vim.api.nvim_create_user_command

local attach_keymaps = function(args)
    local bufnr = args.buf

    bufmap(
        bufnr,
        'n',
        '<Leader>lt',
        '',
        opts {
            'lsp type definition',
            callback = function()
                require('telescope.builtin').lsp_type_definitions {
                    layout_strategies = 'vertical',
                    jump_type = 'tab',
                }
            end,
        }
    )

    -- reference
    bufmap(
        bufnr,
        'n',
        'gr',
        '',
        opts {
            desc = 'lsp references telescope',
            callback = function()
                require('telescope.builtin').lsp_references {
                    layout_strategies = 'vertical',
                    jump_type = 'tab',
                }
            end,
        }
    )

    -- code action
    bufmap(bufnr, 'n', '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts { 'lsp code action' })
    bufmap(
        bufnr,
        'x',
        '<Leader>la',
        ':<C-U>lua vim.lsp.buf.code_action()<CR>',
        opts {
            'lsp range code action',
        }
    )

    -- hover
    bufmap(bufnr, 'n', 'gh', '', opts { 'lsp hover', vim.lsp.buf.hover })
    bufmap(bufnr, 'n', 'K', '', opts { 'lsp hover', vim.lsp.buf.hover })
    bufmap(bufnr, 'i', '<A-h>', '', opts { 'lsp hover', vim.lsp.buf.hover })

    -- signaturehelp
    bufmap(bufnr, 'n', '<Leader>ls', '', opts { 'signature help', vim.lsp.buf.signature_help })
    bufmap(bufnr, 'i', '<A-s>', '', opts { 'signature help', vim.lsp.buf.signature_help })

    -- rename
    bufmap(bufnr, 'n', '<Leader>ln', '<cmd>lua vim.lsp.buf.rename()<CR>', opts { 'lsp rename' })

    -- go to definition, implementation
    bufmap(
        bufnr,
        'n',
        'gd',
        '',
        opts {
            desc = 'lsp go to definition',
            callback = function()
                require('telescope.builtin').lsp_definitions {
                    layout_strategies = 'vertical',
                    jump_type = 'tab',
                }
            end,
        }
    )

    bufmap(
        bufnr,
        'n',
        '<Leader>li',
        '',
        opts {
            desc = 'lsp go to implementation',
            callback = function()
                require('telescope.builtin').lsp_implementations {
                    layout_strategies = 'vertical',
                    jump_type = 'tab',
                }
            end,
        }
    )

    bufmap(
        bufnr,
        'n',
        '<Leader>lci',
        '',
        opts {
            desc = 'lsp incoming calls',
            callback = require('telescope.builtin').lsp_incoming_calls,
        }
    )
    bufmap(
        bufnr,
        'n',
        '<Leader>lco',
        '',
        opts {
            desc = 'lsp outgoing calls',
            callback = require('telescope.builtin').lsp_outgoing_calls,
        }
    )

    -- workspace
    bufcmd(bufnr, 'LspWorkspace', function(options)
        if options.args == 'add' then
            vim.lsp.buf.add_workspace_folder()
        elseif options.args == 'remove' then
            vim.lsp.buf.remove_workspace_folder()
        elseif options.args == 'show' then
            vim.print(vim.lsp.buf.list_workspace_folders())
        end
    end, {
        nargs = 1,
        complete = function(_, _, _)
            return { 'add', 'remove', 'show' }
        end,
    })

    -- format
    bufmap(bufnr, 'n', '<Leader>lf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts { 'lsp format' })
    bufmap(bufnr, 'v', '<Leader>lf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts { 'lsp range format' })

    -- diagnostic
    bufmap(
        bufnr,
        'n',
        '<Leader>ld',
        '<cmd>Telescope diagnostics bufnr=0<CR>',
        opts { 'lsp file diagnostics by telescope' }
    )
    bufmap(
        bufnr,
        'n',
        '<Leader>lw',
        '<cmd>Telescope diagnostics root_dir=true<CR>',
        opts { 'lsp workspace diagnostics by telescope' }
    )
    bufmap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts { 'prev diagnostic' })
    bufmap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts { 'next diagnostic' })

    bufmap(bufnr, 'n', '<leader>lo', '<cmd>AerialToggle!<CR>', opts { 'lsp symbol outline' })
end

autocmd('LspAttach', {
    group = my_augroup,
    callback = attach_keymaps,
    desc = 'Attach lsp keymaps',
})

-- HACK: in nvim 0.9+, lspconfig will set &tagfunc to vim.lsp.tagfunc
-- automatically. For lsp that does not support workspace symbol, this function
-- may cause conflict because `cmp-nvim-tags` which uses tags to search
-- workspace symbol, leading to an error when `vim.lsp.tagfunc` is called. To
-- prevent this behavior, we disable it.
--
-- Besides, vim.lsp.tagfunc also has performance issue if you want to use it in
-- auto completion.

-- Occasionally, due to potential execution order issues: you might set tagfunc
-- to nil, but the LSP could re-register it later. So that you may need a
-- "brute force way" to ask neovim will always fallback to the default tag
-- search method immediately.
TAGFUNC_FALLBACK_IMMEDIATELY = function()
    return vim.NIL
end

-- if tagfunc is already registered, nvim lsp will not try to set tagfunc as vim.lsp.tagfunc.
vim.o.tagfunc = 'v:lua.TAGFUNC_FALLBACK_IMMEDIATELY'

autocmd('LspAttach', {
    group = my_augroup,
    once = true,
    callback = function()
        vim.lsp.handlers['textDocument/signatureHelp'] =
            vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded', max_height = 30, max_width = 80 })
    end,
    desc = 'Set the UI for signature help',
})

autocmd('LspAttach', {
    group = my_augroup,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        client.server_capabilities.semanticTokensProvider = nil
    end,
    desc = 'Disable semantic highlight',
})

-- use nvim-cmp/blink capabilities. Define the capabilities here which will be
-- fetched when lspconfig is loaded
local capabilities

local enabled_lsps = { 'r', 'python', 'bash', 'cpp', 'vim', 'nvim', 'pinyin', 'sql', 'latex', 'go', 'rust', 'efm' }

local lsp_configs = {}

lsp_configs.python = function()
    require('lspconfig').basedpyright.setup {
        capabilities = capabilities,
    }
end

lsp_configs.r = function()
    require('lspconfig').r_language_server.setup {
        capabilities = capabilities,
    }
end

lsp_configs.latex = function()
    require('lspconfig').texlab.setup {
        capabilities = capabilities,
    }
end

lsp_configs.bash = function()
    require('lspconfig').bashls.setup {
        capabilities = capabilities,
    }
end

lsp_configs.cpp = function()
    local clangd_capabilities = vim.deepcopy(capabilities)
    clangd_capabilities.offsetEncoding = { 'utf-16' }

    require('lspconfig').clangd.setup {
        capabilities = clangd_capabilities,
    }
end

lsp_configs.nvim = function()
    require('lspconfig').lua_ls.setup {
        on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
        end,
        capabilities = capabilities,
        settings = {
            Lua = {
                diagnostics = {
                    globals = { 'vim' },
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    }
end

lsp_configs.vim = function()
    require('lspconfig').vimls.setup {
        capabilities = capabilities,
    }
end

lsp_configs.sql = function()
    require('lspconfig').sqls.setup {
        on_attach = function(client, bufnr)
            -- The document formatting implementation of sqls is buggy.
            client.server_capabilities.documentFormattingProvider = false

            require('sqls').on_attach(client, bufnr)
            bufmap(bufnr, 'n', '<LocalLeader>ss', '<cmd>SqlsExecuteQuery<CR>', { silent = true })
            bufmap(bufnr, 'v', '<LocalLeader>ss', '<cmd>SqlsExecuteQuery<CR>', { silent = true })
            bufmap(bufnr, 'n', '<LocalLeader>sv', '<cmd>SqlsExecuteQueryVertical<CR>', { silent = true })
            bufmap(bufnr, 'v', '<LocalLeader>sv', '<cmd>SqlsExecuteQueryVertical<CR>', { silent = true })
        end,
        capabilities = capabilities,
        on_new_config = function(new_config, new_rootdir)
            if vim.fn.filereadable(new_rootdir .. '/config.yml') == 1 then
                new_config.cmd = {
                    'sqls',
                    '-config',
                    new_rootdir .. '/config.yml',
                }
            end
        end,
    }
end

lsp_configs.pinyin = function()
    require('lspconfig').ds_pinyin_lsp.setup {
        filetypes = { 'markdown', 'rmd', 'quarto' },
        init_options = {
            db_path = os.getenv 'HOME' .. '/.local/share/ds-pinyin-lsp/dict.db3',
            completion_on = false, -- don't enable the completion by default
        },
    }
end

lsp_configs.go = function()
    require('lspconfig').gopls.setup {
        capabilities = capabilities,
    }
end

lsp_configs.rust = function()
    local rust_capabilities = vim.deepcopy(capabilities)
    rust_capabilities.experimental = {
        serverStatusNotification = true,
    }
    require('lspconfig').rust_analyzer.setup {
        capabilities = rust_capabilities,
    }
end

lsp_configs.efm = function()
    require('lspconfig').efm.setup {
        filetypes = {
            'python',
            'lua',
            'markdown',
            'lua',
            'org',
            'sql',
            'rmd',
            'quarto',
            'json',
            'yaml',
        },
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
            codeAction = true,
        },
    }
end

vim.fn.sign_define('DiagnosticSignError', { text = '✗', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '!', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInformation', { text = '󰋽', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

local has_virtual_text = false
local has_underline = false

vim.diagnostic.config { virtual_text = has_virtual_text, underline = has_underline }

command('DiagnosticVirtualTextToggle', function()
    has_virtual_text = not has_virtual_text
    vim.diagnostic.config { virtual_text = has_virtual_text }
end, {})

command('DiagnosticUnderlineToggle', function()
    has_underline = not has_underline
    vim.diagnostic.config { underline = has_underline }
end, {})

command('DiagnosticInlineToggle', function()
    vim.cmd.DiagnosticUnderlineToggle()
    vim.cmd.DiagnosticVirtualTextToggle()
end, {})

return {
    -- LSP config
    {
        'neovim/nvim-lspconfig',
        event = 'LazyFile',
        config = function()
            capabilities = require('plugins.completion').completion_frontend == 'blink'
                    and require('blink.cmp').get_lsp_capabilities()
                or require('cmp_nvim_lsp').default_capabilities()

            for _, lsp in pairs(enabled_lsps) do
                lsp_configs[lsp]()
            end
        end,
    },

    -- lsp related tools, including lsp symbols, symbol outline, etc.
    {
        'stevearc/aerial.nvim',
        cmd = 'AerialToggle',
        config = function()
            require('aerial').setup {
                backends = { 'lsp', 'treesitter', 'markdown' },
                close_automatic_events = { 'unsupported' },
                filter_kind = false,
                show_guides = true,
            }
        end,
    },
    {
        'ThePrimeagen/refactoring.nvim',
        init = function()
            autocmd('FileType', {
                pattern = { 'go', 'python', 'lua' },
                desc = 'Load refactoring.nvim',
                callback = function()
                    bufmap(
                        0,
                        'n',
                        '<Leader>lr',
                        '<CMD>lua require("refactoring").select_refactor()<CR>',
                        { desc = 'refactoring' }
                    )
                    bufmap(
                        0,
                        'v',
                        '<Leader>lr',
                        ':lua require("refactoring").select_refactor()<CR>',
                        { desc = 'refactoring' }
                    )
                end,
            })
        end,
        config = function()
            require('refactoring').setup {}
        end,
    },
    {
        'SmiteshP/nvim-navic',
        init = function()
            autocmd('LspAttach', {
                group = my_augroup,
                callback = function(args)
                    local bufnr = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client.server_capabilities.documentSymbolProvider then
                        require('nvim-navic').attach(client, bufnr)
                    end
                end,
                desc = 'Attach navic',
            })
        end,
        config = function()
            require('nvim-navic').setup {
                -- don't update winbar symbols on CursorMoved event to improve
                -- performance.
                lazy_update_context = true,
            }
        end,
    },

    {
        'folke/lazydev.nvim',
        ft = 'lua',
        config = function()
            require('lazydev').setup {
                library = {
                    { path = 'luvit-meta/library', words = { 'vim%.uv' } },
                },
            }
        end,
    },
    -- tyoe hint for vim.uv
    { 'Bilal2453/luvit-meta' },
    { 'nanotee/sqls.nvim' },
}
