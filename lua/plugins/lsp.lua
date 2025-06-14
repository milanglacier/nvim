local enabled_lsps =
    { 'r_language_server', 'basedpyright', 'texlab', 'rust_analyzer', 'gopls', 'lua_ls', 'efm', 'bashls', 'clangd' }

local lsp_to_executable = {
    r_language_server = 'R',
    basedpyright = 'basedpyright',
    texlab = 'texlab',
    rust_analyzer = 'rust-analyzer',
    gopls = 'gopls',
    lua_ls = 'lua-language-server',
    clangd = 'clangd',
    efm = 'efm-langserver',
    bashls = 'bash-language-server',
    sqls = 'sqls',
}

local lsp_to_ft = {
    r_language_server = { 'r', 'rmd' },
    bashls = { 'sh', 'bash' },
    basedpyright = { 'python' },
    texlab = { 'tex' },
    rust_analyzer = { 'rust' },
    gopls = { 'go' },
    lua_ls = { 'lua' },
    clangd = { 'c', 'cpp' },
    sqls = { 'sql' },
    efm = {
        'python',
        'lua',
        'markdown',
        'rmd',
        'quarto',
        'json',
        'yaml',
        'sql',
    },
}

local enabled_fts = {}
for _, lsp in ipairs(enabled_lsps) do
    for _, ft in ipairs(lsp_to_ft[lsp] or {}) do
        enabled_fts[ft] = true
    end
end

enabled_fts = vim.tbl_keys(enabled_fts)

local opts = function(options)
    return {
        noremap = true,
        silent = true,
        desc = options[1] or options.desc,
        callback = options[2] or options.callback,
        nowait = options[3] or options.nowait,
    }
end

local bufmap = vim.api.nvim_buf_set_keymap
local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup
local bufcmd = vim.api.nvim_buf_create_user_command
local command = vim.api.nvim_create_user_command

local attach_keymaps = function(args)
    local bufnr = args.buf

    bufmap(bufnr, 'n', '<Leader>lt', '<cmd>FF lsp_type_definitions<cr>', opts { 'lsp type definition' })

    -- reference
    -- We aim to bypass LSP's default mappings for `grr`, `gra`, and similar
    -- commands by setting `nowait = true` to execute `gr` immediately.
    bufmap(bufnr, 'n', 'gr', '<cmd>FF lsp_references<cr>', opts { 'lsp references', nil, true })

    -- code action
    bufmap(bufnr, 'n', '<Leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts { 'lsp code action' })
    bufmap(bufnr, 'x', '<Leader>la', ':<C-U>lua vim.lsp.buf.code_action()<CR>', opts { 'lsp range code action' })

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
    bufmap(bufnr, 'n', 'gd', '<cmd>FF lsp_definitions<cr>', opts { 'lsp definition' })

    bufmap(bufnr, 'n', '<Leader>li', '<cmd>FF lsp_implementations<cr>', opts { 'lsp go to implementation' })

    bufmap(bufnr, 'n', '<Leader>lci', '<cmd>FF lsp_incoming_calls<cr>', opts { 'lsp incoming calls' })
    bufmap(bufnr, 'n', '<Leader>lco', '<cmd>FF lsp_outgoing_calls<cr>', opts { 'lsp outgoing calls' })

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
    bufmap(bufnr, 'n', '<Leader>ld', '<cmd>FF buf_diagnositcs<CR>', opts { 'lsp buffer diagnostics' })
    bufmap(bufnr, 'n', '<Leader>lw', '<cmd>FF workspace_diagnositcs<CR>', opts { 'lsp workspace diagnostics' })
    bufmap(bufnr, 'n', '[d', '<cmd>lua vim.diagnostic.jump {count = -1, float = true}<CR>', opts { 'prev diagnostic' })
    bufmap(bufnr, 'n', ']d', '<cmd>lua vim.diagnostic.jump {count = 1, float = true}<CR>', opts { 'next diagnostic' })

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
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        ---@diagnostic disable-next-line
        client.server_capabilities.semanticTokensProvider = nil
    end,
    desc = 'Disable semantic highlight',
})

local setup_lspconfig = function()
    vim.lsp.config('lua_ls', {
        on_attach = function(client, _)
            client.server_capabilities.documentFormattingProvider = false
        end,
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
    })

    vim.lsp.config('sqls', {
        on_attach = function(client, bufnr)
            -- The document formatting implementation of sqls is buggy.
            client.server_capabilities.documentFormattingProvider = false

            require('sqls').on_attach(client, bufnr)
            bufmap(bufnr, 'n', '<LocalLeader>ss', '<cmd>SqlsExecuteQuery<CR>', { silent = true })
            bufmap(bufnr, 'v', '<LocalLeader>ss', '<cmd>SqlsExecuteQuery<CR>', { silent = true })
            bufmap(bufnr, 'n', '<LocalLeader>sv', '<cmd>SqlsExecuteQueryVertical<CR>', { silent = true })
            bufmap(bufnr, 'v', '<LocalLeader>sv', '<cmd>SqlsExecuteQueryVertical<CR>', { silent = true })
        end,
    })

    vim.lsp.config('efm', {
        filetypes = {
            'python',
            'lua',
            'markdown',
            'lua',
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
    })
end

autocmd('FileType', {
    once = true,
    desc = 'Setup LSP lazily',
    group = augroup('MyLSPSetup', {}),
    pattern = enabled_fts,
    callback = function()
        setup_lspconfig()
        for _, lsp in ipairs(enabled_lsps) do
            local executable = lsp_to_executable[lsp] or lsp
            if vim.fn.executable(executable) == 1 then
                vim.lsp.enable(lsp)
            end
        end

        -- NOTE: When specifying `once = true`, the autocommand will execute
        -- once *per filetype*, not just once in total. Therefore, we remove
        -- the autocmd itself afterward since all LSPs will already have been
        -- setup by that point.
        vim.api.nvim_del_augroup_by_name 'MyLSPSetup'
    end,
})

local has_virtual_text = false
local has_underline = false

vim.diagnostic.config {
    virtual_text = has_virtual_text,
    underline = has_underline,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = '✗',
            [vim.diagnostic.severity.WARN] = '!',
            [vim.diagnostic.severity.INFO] = '󰋽',
            [vim.diagnostic.severity.HINT] = '',
        },
    },
}

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
                        opts { 'refactoring' }
                    )
                    bufmap(
                        0,
                        'v',
                        '<Leader>lr',
                        ':lua require("refactoring").select_refactor()<CR>',
                        opts { 'refactoring' }
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

                    -- disable navic for quarto, as navic does not work well with otter-ls.
                    if vim.bo[bufnr].ft == 'quarto' then
                        return
                    end

                    ---@diagnostic disable-next-line
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
                    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                },
            }
        end,
    },
    { 'nanotee/sqls.nvim' },
}
