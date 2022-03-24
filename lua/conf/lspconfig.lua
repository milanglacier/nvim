-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    --  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>td', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    --
    --  vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    -- vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    -- vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    --

    -- find definition and reference simultaneously
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", opts)
    -- open a separate window to show reference


    -- reference
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr',
        "<cmd>lua require 'telescope.builtin'.lsp_references({layout_strategy = 'vertical', jump_type = 'tab'})<CR>", opts)

    -- code action
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>ca',
        "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'v', '<Leader>ca',
        ":lua require('lspsaga.codeaction').range_code_action()<CR>", opts)

    -- hover
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gh',
        "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-f>',
        "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-b>',
        "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)

    -- signaturehelp
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>sh',
        "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)
    -- "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

    -- rename
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>rn',
        '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    -- go to definition, implementation
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd',
        "<cmd>lua require 'telescope.builtin'.lsp_definitions({layout_strategy = 'vertical', jump_type = 'tab'})<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>gi', "<cmd>lua require'telescope.builtin'.lsp_implementations({layout_strategy = 'vertical', jump_type = 'tab'})<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>", opts)

    -- workspace
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

    -- format
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'v', '<Leader>fl', ':<C-U>lua vim.lsp.buf.range_formatting()<CR>', opts)


    -- diagnostic
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>ds', "<cmd>lua require'telescope.builtin'.diagnostics()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', ":Lspsaga diagnostic_jump_prev<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', ":Lspsaga diagnostic_jump_next<CR>", opts)
    -- diagnostic show in line or in cursor
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>dl', "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>dc', "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>", opts)

    require("aerial").on_attach(client, bufnr)
    require("conf.signature").on_attach(bufnr)


end


-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- --
-- -- -- copied from https://github.com/ray-x/lsp_signature.nvim/blob/master/tests/init_paq.lua
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
}

require'lspconfig'.pylsp.setup{
    cmd = {require 'bin_path'.pylsp},
    on_attach = on_attach,
    flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
    },
    capabilities = capabilities,

}

require'lspconfig'.r_language_server.setup{
    on_attach = on_attach,
    flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
    },
    capabilities = capabilities,
    --root_dir = function()
    --return root_pattern(".git") or vim.fn.getcwd()
    --end

}
require'lspconfig'.texlab.setup{
    on_attach = on_attach,
    flags = {debounce_text_changes = 150},
    capabilities = capabilities
}

require'lspconfig'.julials.setup{
    on_attach = on_attach,
    flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
    },
    capabilities = capabilities,

}


require'lspconfig'.clangd.setup{
    on_attach = on_attach,
    capabilities = capabilities
}

local lua_runtime_path = vim.split(package.path, ';')
table.insert(lua_runtime_path, "lua/?.lua")
table.insert(lua_runtime_path, "lua/?/init.lua")

require("lua-dev").setup({})

require'lspconfig'.sumneko_lua.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                path = lua_runtime_path,
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'},
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

require'lspconfig'.vimls.setup{
    on_attach = on_attach,
    capabilities = capabilities,
}

vim.fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
