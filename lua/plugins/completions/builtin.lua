local M = {}
local my_augroup = require('conf.builtin_extend').my_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap

if Milanglacier.completion_frontend == 'builtin' then
    if vim.fn.has 'nvim-0.12' == 1 then
        vim.o.autocomplete = true
        -- Add omnifunc (`o`) to the `complete` list, which is bound to
        -- `vim.lsp.omnifunc` by default.
        vim.o.complete = 'o,.^15,w^10,b^10,t^20'
        vim.o.autocompletedelay = 100
    else
        vim.notify 'vim.o.autocomplete requires Neovim 0.12+'
    end
elseif Milanglacier.completion_frontend == 'mini' then
    autocmd('InsertEnter', {
        group = my_augroup,
        once = true,
        callback = function()
            require('mini.completion').setup {
                -- don't let mini modify my completeopt
                set_vim_settings = false,
                delay = { signature = 1e7 }, -- disable signature help
                lsp_completion = { auto_setup = false, source_func = 'completefunc' },
                mappings = {
                    -- disable default mapping
                    force_twostep = '',
                    force_fallback = '',
                    scroll_down = '',
                    scroll_up = '',
                },
            }
            vim.o.completefunc = 'v:lua.MiniCompletion.completefunc_lsp'
        end,
        desc = 'Enable mini auto completion',
    })
end

autocmd('FileType', {
    group = my_augroup,
    pattern = { 'snacks_picker_input' },
    desc = 'Disable autocompletion',
    callback = function()
        vim.b.minicompletion_disable = true
        if vim.fn.has 'nvim-0.12' == 1 then
            vim.bo.autocomplete = false
        end
    end,
})

autocmd('CmdlineEnter', {
    group = my_augroup,
    nested = true,
    once = true,
    callback = function()
        require('mini.cmdline').setup {
            autocomplete = {
                delay = 0,
            },
            autopeek = { enable = false },
        }
        -- Manually trigger the CmdlineEnter autocmd from the
        -- MiniCmdline group. This is necessary because
        -- mini.cmdline is being lazy-loaded during the
        -- CmdlineEnter event itself. To ensure it works
        -- immediately, we must manually invoke the relevant
        -- autocmd.
        vim.api.nvim_exec_autocmds('CmdlineEnter', {
            group = 'MiniCmdline',
        })
    end,
    desc = 'Enable mini cmdline completion',
})

local function keycode(keys)
    return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

local function feedkeys(keys)
    -- the magic character 'n' means that we want noremap behavior
    vim.api.nvim_feedkeys(keycode(keys), 'n', false)
end

keymap('i', '<A-y>', '<C-x><C-o>', {
    desc = 'Manual invoke LSP completion',
})

-- the behavior of tab is depending on scenario:
-- if snippet has next jumpable anchor, then jump to it
-- if popup menu is visible, then select next completion
-- else just fallback to the default tab behavior
for _, mode in ipairs { 'i', 's' } do
    keymap(mode, '<tab>', '', {
        desc = 'tab DWIM',
        callback = function()
            local luasnip = require 'luasnip'

            if luasnip.expand_or_jumpable() then
                if vim.fn.pumvisible() == 1 then
                    -- close pum firstly before expanding snippet
                    feedkeys '<C-e>'
                end
                vim.schedule(luasnip.expand_or_jump)
            elseif vim.snippet.active() then
                vim.snippet.jump(1)
            elseif vim.fn.pumvisible() == 1 then
                feedkeys '<C-n>'
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
