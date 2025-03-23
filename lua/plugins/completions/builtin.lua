local M = {}
local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap

-- TODO: move this to basic_settings.lua once neovim 0.11 is officially
-- released.
vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'

if Milanglacier.completion_frontend == 'builtin' then
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
elseif Milanglacier.completion_frontend == 'mini' then
    autocmd('InsertEnter', {
        group = my_augroup,
        once = true,
        callback = function()
            require('mini.completion').setup {
                -- don't let mini modify my completeopt
                set_vim_settings = false,
                delay = { signature = 1e7 }, -- disable signature help
                lsp_completion = { auto_setup = false, source_func = 'omnifunc' },
                mappings = {
                    -- disable default mapping
                    force_twostep = '',
                    force_fallback = '',
                    scroll_down = '',
                    scroll_up = '',
                },
            }
            vim.o.omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
        end,
        desc = 'Enable mini auto completion',
    })
end

local function keycode(keys)
    return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feedkeys(keys)
    -- the magic character 'n' means that we want noremap behavior
    vim.api.nvim_feedkeys(keycode(keys), 'n', true)
end

keymap('i', '<A-y>', '<cmd>lua vim.lsp.completion.get()<CR>', { desc = 'Manual invoke LSP completion', noremap = true })
-- Respect the default behavior: abort completion for `pum` or, otherwise, go to the line end.
keymap('i', '<C-e>', '', {
    desc = 'Go to line end but respect pum',
    noremap = true,
    expr = true,
    callback = function()
        if vim.fn.pumvisible() == 1 then
            return keycode '<C-e>'
        else
            return keycode '<end>'
        end
    end,
})

-- the behavior of tab is depending on scenario:
-- if popup menu is visible, then select next completion
-- if snippet has next jumpable anchor, then jump to it
-- else just fallback to the default tab behavior
for _, mode in ipairs { 'i', 's' } do
    keymap(mode, '<tab>', '', {
        desc = 'tab DWIM',
        callback = function()
            local luasnip = require 'luasnip'

            if vim.fn.pumvisible() == 1 then
                feedkeys '<C-n>'
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif vim.snippet.active() then
                vim.snippet.jump(1)
            else
                feedkeys '<tab>'
            end
        end,
        noremap = true,
    })
end

-- the behavior of backtab is depending on scenario:
-- if popup menu is visible, then select prev completion
-- if snippet has previous jumpable anchor, then jump to it
-- else just fallback to the default backtab behavior
for _, mode in ipairs { 'i', 's' } do
    keymap(mode, '<S-tab>', '', {
        desc = 'backtab DWIM',
        callback = function()
            local luasnip = require 'luasnip'

            if vim.fn.pumvisible() == 1 then
                feedkeys '<C-p>'
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            elseif vim.snippet.active { direction = -1 } then
                vim.snippet.jump(-1)
            else
                feedkeys '<S-tab>'
            end
        end,
        noremap = true,
    })
end

return M
