local M = {}
local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap

-- TODO: move this to basic_settings.lua once neovim 0.11 is officially
-- released.
vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'

-- use neovim built-in completion. Requires nvim-0.11+

autocmd('LspAttach', {
    group = my_augroup,
    callback = function(args)
        local client_id = args.data.client_id
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(client_id)
        if not client then
            return
        end

        if client.server_capabilities.completionProvider and client.name ~= 'minuet' then
            vim.lsp.completion.enable(true, client_id, bufnr, { autotrigger = true })
        end
    end,
    desc = 'Enable built-in auto completion',
})

keymap('i', '<A-y>', '<cmd>lua vim.lsp.completion.get()<CR>', { desc = 'Manual invoke LSP completion' })

return M
