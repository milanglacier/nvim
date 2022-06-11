-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.cmd [[packadd! nvim-lspconfig]]
vim.cmd [[packadd! lspsaga.nvim]]
vim.cmd [[packadd! aerial.nvim]]
vim.cmd [[packadd! lsp_signature.nvim]]
vim.cmd [[packadd! lua-dev.nvim]]

local key_opts = function(options)
    return {
        noremap = true,
        silent = true,
        desc = options[1] or options.desc,
        callback = options[2] or options.callback,
    }
end

local on_attach = function(client, bufnr)
    local bufmap = vim.api.nvim_buf_set_keymap

    bufmap(bufnr, 'n', '<Leader>td', '<cmd>lua vim.lsp.buf.type_definition()<CR>', key_opts { 'lsp type definition' })

    -- reference
    bufmap(
        bufnr,
        'n',
        'gr',
        '',
        key_opts {
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
    -- bufmap(bufnr, 'n', '<Leader>ca', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts {})
    -- bufmap(bufnr, 'v', '<Leader>ca', ":lua require('lspsaga.codeaction').range_code_action()<CR>", opts {})
    bufmap(bufnr, 'n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', key_opts { 'lsp code action' })
    bufmap(
        bufnr,
        'x',
        '<Leader>ca',
        ':<C-U>lua vim.lsp.buf.range_code_action()<CR>',
        key_opts {
            'lsp range code action',
        }
    )

    -- hover
    bufmap(bufnr, 'n', 'gh', '<cmd>Lspsaga hover_doc<CR>', key_opts { 'lspsaga hover doc' })
    bufmap(
        bufnr,
        'n',
        '<C-f>',
        '',
        key_opts {
            desc = 'lspsaga smartscroll downward',
            callback = function()
                require('lspsaga.action').smart_scroll_with_saga(1, '<C-f>')
            end,
        }
    )
    bufmap(
        bufnr,
        'n',
        '<C-b>',
        '',
        key_opts {
            desc = 'lspsaga smartscroll upward',
            callback = function()
                require('lspsaga.action').smart_scroll_with_saga(-1, '<C-b>')
            end,
        }
    )

    -- use glow-hover
    bufmap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', key_opts { 'lsp hover by glow' })

    -- signaturehelp
    bufmap(
        bufnr,
        'n',
        '<Leader>sh',
        '',
        key_opts { 'lspsaga signature help', require('lspsaga.signaturehelp').signature_help }
    )
    -- "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

    -- rename
    bufmap(bufnr, 'n', '<Leader>rn', '<cmd>Lspsaga rename<CR>', key_opts { 'lspsaga rename' })

    -- go to definition, implementation
    bufmap(
        bufnr,
        'n',
        'gd',
        '',
        key_opts {
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
        '<Leader>gi',
        '',
        key_opts {
            desc = 'lsp go to implementation',
            callback = function()
                require('telescope.builtin').lsp_implementations {
                    layout_strategies = 'vertical',
                    jump_type = 'tab',
                }
            end,
        }
    )
    -- keymap(bufnr, 'n', 'gd', "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>", opts)

    -- workspace
    local bufcmd = vim.api.nvim_buf_create_user_command

    bufcmd(bufnr, 'LspWorkspace', function(options)
        if options.args == 'add' then
            vim.lsp.buf.add_workspace_folder()
        elseif options.args == 'remove' then
            vim.lsp.buf.remove_workspace_folder()
        elseif options.args == 'show' then
            vim.pretty_print(vim.lsp.buf.list_workspace_folders())
        end
    end, {
        nargs = 1,
        complete = function(_, _, _)
            return { 'add', 'remove', 'show' }
        end,
    })

    -- format
    bufmap(bufnr, 'n', '<Leader>fm', '', key_opts { 'lsp format', vim.lsp.buf.formatting })
    bufmap(bufnr, 'v', '<Leader>fm', ':<C-U>lua vim.lsp.buf.range_formatting()<CR>', key_opts { 'lsp range format' })

    -- diagnostic
    bufmap(
        bufnr,
        'n',
        '<Leader>ds',
        '',
        key_opts { 'lsp diagnostics by telescope', require('telescope.builtin').diagnostics }
    )
    bufmap(bufnr, 'n', '[d', '<cmd>Lspsaga diagnostic_jump_prev<CR>', key_opts { 'lspsaga prev diagnostic' })
    bufmap(bufnr, 'n', ']d', '<cmd>Lspsaga diagnostic_jump_next<CR>', key_opts { 'lspsaga next diagnostic' })
    -- diagnostic show in line or in cursor
    bufmap(
        bufnr,
        'n',
        '<Leader>dl',
        '<cmd>Lspsaga show_line_diagnostics<CR>',
        key_opts { 'lspsaga current line diagnostic' }
    )

    require('aerial').on_attach(client, bufnr)
    require('conf.lsp_tools').signature(bufnr)
end

-- Setup lspconfig.
-- -- -- copied from https://github.com/ray-x/lsp_signature.nvim/blob/master/tests/init_paq.lua
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
}

-- Copied from lspconfig/server_configurations/pylsp.lua
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
        python = {
            pythonPath = require('bin_path').python,
        },
    },
    flags = {
        debounce_text_changes = 250,
    },
}

local r_config = {
    on_attach = on_attach,
    flags = {
        debounce_text_changes = 300,
    },
    capabilities = capabilities,
    settings = {
        r = {
            lsp = {
                -- debug = true,
                log_file = '~/.cache/nvim/r_lsp_log.log',
                lint_cache = true,
                -- max_completions = 40,
            },
        },
    },
    on_init = function(_)
        local timer = vim.loop.new_timer()
        timer:start(
            2000,
            2000,
            vim.schedule_wrap(function()
                local active_clients = vim.lsp.get_active_clients()
                local lsp_names = {}
                for _, lsp in pairs(active_clients) do
                    table.insert(lsp_names, lsp.name)
                end

                if not vim.tbl_contains(lsp_names, 'r_language_server') then
                    vim.notify('r-lsp exits', vim.log.levels.WARN)
                    timer:close()

                    vim.cmd [[LspStart r_language_server]]
                end
            end)
        )
    end,
}

require('lspconfig').r_language_server.setup(r_config)

require('lspconfig').texlab.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

require('lspconfig').bashls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

local clangd_capabilities = vim.deepcopy(capabilities)
clangd_capabilities.offsetEncoding = { 'utf-16' }

require('lspconfig').clangd.setup {
    on_attach = on_attach,
    capabilities = clangd_capabilities,
}

local lua_runtime_path = {}
table.insert(lua_runtime_path, 'lua/?.lua')
table.insert(lua_runtime_path, 'lua/?/init.lua')

require('lua-dev').setup {}

require('lspconfig').sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                version = 'LuaJIT',
                path = lua_runtime_path,
            },
            diagnostics = {
                globals = { 'vim' },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file('', true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
}

require('lspconfig').vimls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

require('lspconfig').sqls.setup {
    cmd = { require('bin_path').sqls },
    on_attach = function(client, bufnr)
        vim.cmd [[packadd! sqls.nvim]]

        on_attach(client, bufnr)
        require('sqls').on_attach(client, bufnr)
        local bufmap = vim.api.nvim_buf_set_keymap
        bufmap(bufnr, 'n', '<LocalLeader>ss', '<cmd>SqlsExecuteQuery<CR>', { silent = true })
        bufmap(bufnr, 'v', '<LocalLeader>ss', '<cmd>SqlsExecuteQuery<CR>', { silent = true })
        bufmap(bufnr, 'n', '<LocalLeader>sv', '<cmd>SqlsExecuteQueryVertical<CR>', { silent = true })
        bufmap(bufnr, 'v', '<LocalLeader>sv', '<cmd>SqlsExecuteQueryVertical<CR>', { silent = true })
    end,
    capabilities = capabilities,
    single_file_support = false,
    on_new_config = function(new_config, new_rootdir)
        new_config.cmd = {
            require('bin_path').sqls,
            '-config',
            new_rootdir .. '/config.yml',
        }
    end,
}

vim.fn.sign_define('DiagnosticSignError', { text = '✗', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '!', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInformation', { text = '', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

local command = vim.api.nvim_create_user_command
local bufcmd = vim.api.nvim_buf_create_user_command
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

local has_virtual_text = true
local has_underline = true

command('DiagnosticVirtualTextToggle', function()
    has_virtual_text = not has_virtual_text
    vim.diagnostic.config { virtual_text = has_virtual_text }
end, {})

command('DiagnosticUnderlineToggle', function()
    has_underline = not has_underline
    vim.diagnostic.config { underline = has_underline }
end, {})

local r_config_modifiable = vim.deepcopy(r_config)
r_config_modifiable.filetypes = { 'r', 'rmd' }

local is_lsp_enabled = {
    r = true,
    rmd = true,
}
local has_source = {
    tags = true,
    buffer = true,
}

local cmp_sources = {
    {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'tags' },
    },
    {
        { name = 'buffer' },
        { name = 'path' },
        { name = 'latex_symbols' },
    },
}

local function remove_lsp(ft)
    local ft_table = r_config_modifiable.filetypes

    if is_lsp_enabled[ft] == true then
        for idx, val in pairs(ft_table) do
            if val == ft then
                table.remove(ft_table, idx)
                is_lsp_enabled[ft] = false
            end
        end

        require('lspconfig').r_language_server.setup(r_config_modifiable)
    end
end

local function add_lsp(ft)
    local ft_table = r_config_modifiable.filetypes

    if is_lsp_enabled[ft] == false then
        table.insert(ft_table, ft)
        is_lsp_enabled[ft] = true
        require('lspconfig').r_language_server.setup(r_config_modifiable)
    end
end

local function toggle_lsp(ft)
    if is_lsp_enabled[ft] == true then
        remove_lsp(ft)
    elseif is_lsp_enabled[ft] == false then
        add_lsp(ft)
    end
end

local function remove_source(source, ft)
    local cmp = require 'cmp'

    local sources_priority_1st = cmp_sources[1]
    local sources_priority_2nd = cmp_sources[2]

    if has_source[source] == true then
        for idx, val in pairs(sources_priority_1st) do
            if val.name == source then
                table.remove(sources_priority_1st, idx)
                has_source[source] = false
            end
        end

        for idx, val in pairs(sources_priority_2nd) do
            if val.name == source then
                table.remove(sources_priority_2nd, idx)
                has_source[source] = false
            end
        end

        cmp.setup.filetype(ft, {
            sources = cmp.config.sources(unpack(cmp_sources)),
        })
    end
end

local function add_source(source, ft)
    local cmp = require 'cmp'

    local sources_priority_1 = cmp_sources[1]
    local sources_priority_2 = cmp_sources[2]

    if has_source[source] == false then
        if source == 'tags' then
            table.insert(sources_priority_1, { name = 'tags' })
            has_source[source] = true
        end
        if source == 'buffer' then
            table.insert(sources_priority_2, 1, { name = 'buffer' })
            has_source[source] = true
        end
        cmp.setup.filetype(ft, {
            sources = cmp.config.sources(unpack(cmp_sources)),
        })
    end
end

local function toggle_source(source, ft)
    if has_source[source] == true then
        remove_source(source, ft)
    elseif has_source[source] == false then
        add_source(source, ft)
    end
end

autocmd('FileType', {
    desc = 'set command for setting completion sources.',
    pattern = { 'rmd', 'r' },
    group = my_augroup,
    callback = function()
        bufcmd(0, 'CompletionSwitchTo', function(options)
            if options.args == 'lsp' then
                add_lsp 'rmd'
                remove_source('buffer', vim.bo.filetype)
            elseif options.args == 'buffer' then
                remove_lsp(vim.bo.filetype)
                add_source('buffer', vim.bo.filetype)
            end
        end, {
            nargs = 1,
            complete = function(_, _, _)
                return { 'lsp', 'buffer' }
            end,
        })

        bufcmd(0, 'CompletionEnable', function(options)
            if options.args == 'lsp' then
                add_lsp(vim.bo.filetype)
            elseif options.args == 'buffer' then
                add_source('buffer', vim.bo.filetype)
            elseif options.args == 'tags' then
                add_source('tags', vim.bo.filetype)
            end
        end, {
            nargs = 1,
            complete = function(_, _, _)
                return { 'lsp', 'buffer', 'tags' }
            end,
        })

        bufcmd(0, 'CompletionDisable', function(options)
            if options.args == 'lsp' then
                remove_lsp(vim.bo.filetype)
            elseif options.args == 'buffer' then
                remove_source('buffer', vim.bo.filetype)
            elseif options.args == 'tags' then
                remove_source('tags', vim.bo.filetype)
            end
        end, {
            nargs = 1,
            complete = function(_, _, _)
                return { 'lsp', 'buffer', 'tags' }
            end,
        })

        bufcmd(0, 'CompletionToggle', function(options)
            if options.args == 'lsp' then
                toggle_lsp(vim.bo.filetype)
            elseif options.args == 'buffer' then
                toggle_source('buffer', vim.bo.filetype)
            elseif options.args == 'tags' then
                toggle_source('tags', vim.bo.filetype)
            end
        end, {
            nargs = 1,
            complete = function(_, _, _)
                return { 'lsp', 'buffer', 'tags' }
            end,
        })
    end,
})
