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

local attach_keymaps = function()
    bufmap(0, 'n', '<Leader>lt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts { 'lsp type definition' })

    -- reference
    bufmap(
        0,
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

    bufmap(0, 'n', '<Leader>lF', '<cmd>Lspsaga lsp_finder<CR>', opts { 'lspsaga finder' })

    -- code action
    -- bufmap(bufnr, 'n', '<Leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts {})
    -- bufmap(bufnr, 'v', '<Leader>ca', ":lua require('lspsaga.codeaction').range_code_action()<CR>", opts {})
    bufmap(0, 'n', '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts { 'lsp code action' })
    bufmap(
        0,
        'x',
        '<Leader>la',
        ':<C-U>lua vim.lsp.buf.code_action()<CR>',
        opts {
            'lsp range code action',
        }
    )

    -- hover
    bufmap(0, 'n', 'gh', '', opts { 'lsp hover', vim.lsp.buf.hover })

    bufmap(0, 'n', 'K', '', opts { 'lsp hover', vim.lsp.buf.hover })

    -- signaturehelp
    bufmap(0, 'n', '<Leader>ls', '', opts { 'signature help', vim.lsp.buf.signature_help })

    -- rename
    bufmap(0, 'n', '<Leader>ln', '<cmd>Lspsaga rename<CR>', opts { 'lspsaga rename' })

    -- go to definition, implementation
    bufmap(
        0,
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
        0,
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
        0,
        'n',
        '<Leader>lci',
        '',
        opts {
            desc = 'lsp incoming calls',
            callback = require('telescope.builtin').lsp_incoming_calls,
        }
    )
    bufmap(
        0,
        'n',
        '<Leader>lco',
        '',
        opts {
            desc = 'lsp outgoing calls',
            callback = require('telescope.builtin').lsp_outgoing_calls,
        }
    )

    bufmap(0, 'n', '<Leader>lp', '<cmd>Lspsaga peek_definition<CR>', opts { 'lspsaga preview definition' })
    bufmap(0, 'n', '<Leader>lT', '<cmd>Lspsaga peek_type_definition<CR>', opts { 'lspsaga preview type definition' })

    -- workspace
    bufcmd(0, 'LspWorkspace', function(options)
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
    bufmap(0, 'n', '<Leader>lf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts { 'lsp format' })
    bufmap(0, 'v', '<Leader>lf', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts { 'lsp range format' })

    -- diagnostic
    bufmap(0, 'n', '<Leader>ld', '<cmd>Telescope diagnostics bufnr=0<CR>', opts { 'lsp file diagnostics by telescope' })
    bufmap(
        0,
        'n',
        '<Leader>lw',
        '<cmd>Telescope diagnostics root_dir=true<CR>',
        opts { 'lsp workspace diagnostics by telescope' }
    )
    bufmap(0, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts { 'lspsaga prev diagnostic' })
    bufmap(0, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts { 'lspsaga next diagnostic' })
    -- diagnostic show in line or in cursor
    bufmap(0, 'n', '<Leader>ll', '<cmd>Lspsaga show_line_diagnostics<CR>', opts { 'lspsaga line diagnostic' })

    bufmap(0, 'n', '<leader>lo', '<cmd>AerialToggle!<CR>', opts { 'lsp symbol outline' })
end

autocmd('LspAttach', {
    group = my_augroup,
    callback = attach_keymaps,
    desc = 'Attach lsp keymaps',
})

autocmd('LspAttach', {
    group = my_augroup,
    callback = function()
        -- HACK: in nvim 0.9+, lspconfig will set &tagfunc to vim.lsp.tagfunc
        -- automatically. For lsp that does not support workspace symbol, this
        -- function may cause conflict because `cmp-nvim-tags` which uses tags
        -- to search workspace symbol, leading to an error when
        -- `vim.lsp.tagfunc` is called. To prevent this behavior, we disable
        -- it. Besides, vim.lsp.tagfunc also has performance issue if you want
        -- to use it in completion.
        vim.bo.tagfunc = nil
    end,
    desc = 'Do not use lsp as tagfunc.',
})

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

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Copied from lspconfig/server_configurations/pylsp.lua

local enabled_lsps = { 'r', 'python', 'bash', 'cpp', 'vim', 'nvim', 'pinyin', 'sql', 'latex', 'go', 'rust', 'efm' }

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
        capabilities = capabilities,
        root_dir = python_root_dir,
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
    require('neodev').setup {}

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
        filetypes = { 'markdown', 'markdown.pandoc', 'rmd', 'quarto' },
        init_options = {
            db_path = os.getenv 'HOME' .. '/Downloads/dict.db3',
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
            'markdown.pandoc',
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

for _, lsp in pairs(enabled_lsps) do
    lsp_configs[lsp]()
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
