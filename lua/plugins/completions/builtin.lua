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

keymap('i', '<A-y>', '<cmd>lua vim.lsp.completion.get()<CR>', { desc = 'Manual invoke LSP completion', noremap = true })

local function feedkeys(keys)
    -- the magic character 'n' means that we want noremap behavior
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
end

-- the behavior of tab is depending on scenario:
-- if popup menu is visible, then select next completion
-- if snippet has next jumpable anchor, then jump to it
-- else just fallback to the default tab behavior
keymap('i', '<tab>', '', {
    desc = 'tab DWIM',
    callback = function()
        local luasnip = require 'luasnip'

        if vim.fn.pumvisible() == 1 then
            feedkeys '<C-n>'
        elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
        else
            feedkeys '<tab>'
        end
    end,
    noremap = true,
})

-- the behavior of backtab is depending on scenario:
-- if popup menu is visible, then select prev completion
-- if snippet has previous jumpable anchor, then jump to it
-- else just fallback to the default backtab behavior
keymap('i', '<S-tab>', '', {
    desc = 'backtab DWIM',
    callback = function()
        local luasnip = require 'luasnip'

        if vim.fn.pumvisible() == 1 then
            feedkeys '<C-p>'
        elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
        else
            feedkeys '<S-tab>'
        end
    end,
    noremap = true,
})

return M
