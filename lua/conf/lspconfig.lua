-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.cmd.packadd { 'nvim-lspconfig', bang = true }
vim.cmd.packadd { 'lspsaga.nvim', bang = true }
vim.cmd.packadd { 'aerial.nvim', bang = true }
vim.cmd.packadd { 'lsp_signature.nvim', bang = true }
vim.cmd.packadd { 'neodev.nvim', bang = true }
vim.cmd.packadd { 'nvim-navic', bang = true }

local opts = function(options)
    return {
        noremap = true,
        silent = true,
        desc = options[1] or options.desc,
        callback = options[2] or options.callback,
    }
end

local bufmap = vim.api.nvim_buf_set_keymap

local on_attach = function(client, bufnr)
    bufmap(bufnr, 'n', '<Leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts { 'lsp type definition' })

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

    bufmap(bufnr, 'n', '<Leader>lF', '<cmd>Lspsaga lsp_finder<CR>', opts { 'lspsaga finder' })

    -- code action
    -- bufmap(bufnr, 'n', '<Leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts {})
    -- bufmap(bufnr, 'v', '<Leader>ca', ":lua require('lspsaga.codeaction').range_code_action()<CR>", opts {})
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
    bufmap(
        bufnr,
        'n',
        'gh',
        '',
        opts {
            'lsp hover doc with builtin renderer.',
            function()
                vim.lsp.buf.hover()
                -- after typing gh, within 400 milliseconds typing h will switch into the popup window
                vim.api.nvim_buf_set_keymap(0, 'n', 'h', '', {
                    callback = function()
                        local current_buf = vim.api.nvim_get_current_buf()
                        vim.lsp.buf.hover()
                        vim.defer_fn(function()
                            vim.api.nvim_buf_del_keymap(current_buf, 'n', 'h')
                        end, 400)
                    end,
                })
            end,
        }
    )

    -- use glow-hover
    bufmap(
        bufnr,
        'n',
        'K',
        '',
        opts {
            'lsp hover',
            vim.lsp.buf.hover,
        }
    )

    -- signaturehelp
    bufmap(bufnr, 'n', '<Leader>ls', '', opts { 'signature help', vim.lsp.buf.signature_help })

    -- rename
    bufmap(bufnr, 'n', '<Leader>ln', '<cmd>Lspsaga rename<CR>', opts { 'lspsaga rename' })

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

    bufmap(bufnr, 'n', '<Leader>lp', '<cmd>Lspsaga peek_definition<CR>', opts { 'lspsaga preview definition' })
    bufmap(
        bufnr,
        'n',
        '<Leader>lT',
        '<cmd>Lspsaga peek_type_definition<CR>',
        opts { 'lspsaga preview type definition' }
    )

    -- workspace
    local bufcmd = vim.api.nvim_buf_create_user_command

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
    bufmap(bufnr, 'n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', opts { 'lspsaga prev diagnostic' })
    bufmap(bufnr, 'n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts { 'lspsaga next diagnostic' })
    -- diagnostic show in line or in cursor
    bufmap(bufnr, 'n', '<Leader>ll', '<cmd>Lspsaga show_line_diagnostics<CR>', opts { 'lspsaga line diagnostic' })

    require('conf.lsp_tools').signature(bufnr)

    if client.server_capabilities.documentSymbolProvider then
        require('nvim-navic').attach(client, bufnr)
    end
end

-- Setup lspconfig.
-- -- -- copied from https://github.com/ray-x/lsp_signature.nvim/blob/master/tests/init_paq.lua
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- disable semantic tokens
capabilities.semanticTokensProvider = false

-- Copied from lspconfig/server_configurations/pylsp.lua

local enabled_lsps = { 'r', 'python', 'bash', 'cpp', 'vim', 'nvim', 'pinyin', 'sql', 'latex', 'go' }

local lsp_configs = {}

lsp_configs.python = function()
    local function python_root_dir(fname)
        local util = require 'lspconfig.util'
        local root_files = {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
        }
        return util.root_pattern(unpack(root_files))(fname) or util.find_git_ancestor(fname)
    end

    require('lspconfig').pyright.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = python_root_dir,
        settings = {
            python = {},
        },
        flags = {
            debounce_text_changes = 250,
        },
    }
end

lsp_configs.r = function()
    local r_config = {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 300,
        },
        capabilities = capabilities,
        settings = {
            r = {
                lsp = {
                    log_file = '~/.cache/nvim/r_lsp_log.log',
                    diagnostics = false, -- r-lsp + lintr is currently problematic
                },
            },
        },
    }

    require('lspconfig').r_language_server.setup(r_config)
end

lsp_configs.latex = function()
    require('lspconfig').texlab.setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

lsp_configs.bash = function()
    require('lspconfig').bashls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

lsp_configs.cpp = function()
    local clangd_capabilities = vim.deepcopy(capabilities)
    clangd_capabilities.offsetEncoding = { 'utf-16' }

    require('lspconfig').clangd.setup {
        on_attach = on_attach,
        capabilities = clangd_capabilities,
    }
end

lsp_configs.nvim = function()
    require('neodev').setup {}

    require('lspconfig').lua_ls.setup {
        on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            on_attach(client, bufnr)
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
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

lsp_configs.sql = function()
    require('lspconfig').sqls.setup {
        on_attach = function(client, bufnr)
            vim.cmd.packadd { 'sqls.nvim', bang = true }

            on_attach(client, bufnr)

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
        filetypes = { 'markdown', 'markdown.pandoc', 'rmd', 'quarto' },
        init_options = {
            db_path = os.getenv 'HOME' .. '/Downloads/dict.db3',
            completion_on = false, -- don't enable the completion by default
        },
    }
end

lsp_configs.go = function()
    require('lspconfig').gopls.setup {
        on_attach = on_attach,
    }
end

for _, lsp in pairs(enabled_lsps) do
    lsp_configs[lsp]()
end

vim.fn.sign_define('DiagnosticSignError', { text = '✗', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '!', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInformation', { text = '', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

local command = vim.api.nvim_create_user_command

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
