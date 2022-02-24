-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    --  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    --  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    --
    --  vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    -- vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    -- vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    --
    
    -- find definition and reference simutaneously
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", opts)
    -- open a seperate window to show reference


    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr',
        "<cmd>lua require 'telescope.builtin'.lsp_references({jump_type = 'vsplit'})<CR>", opts)

    -- code action
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>ca',
        "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'v', '<Leader>ca',
        "<C-U>lua lua require('lspsaga.codeaction').range_code_action()<CR>", opts)

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

    -- rename
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>rn',
        '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

    -- preview definition
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd',
        "<cmd>lua require 'telescope.builtin'.lsp_definitions({jump_type = 'vsplit'})<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>gd', "<cmd>lua vim.lsp.buf.definition()<CR>", opts)


    -- workspace
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n',
        '<Leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

    -- format
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)


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

end


-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require'lspconfig'.pylsp.setup{
    cmd = {vim.api.nvim_eval("CONDA_PATHNAME") .. "/bin/pylsp"},
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

require'lspconfig'.julials.setup{
    on_attach = on_attach,
    flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
    },
    root_dir = function(fname) 
        return util.root_pattern 'Project.toml'(fname) or util.find_git_ancestor(fname) 
    end, 
    capabilities = capabilities,

}

vim.fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

vim.cmd([[
set completeopt=menu,menuone,noselect
]])

