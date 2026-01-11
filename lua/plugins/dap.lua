local keymap = vim.api.nvim_set_keymap
local bufmap = vim.api.nvim_buf_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local myaugroup = require('conf.builtin_extend').my_augroup

return {
    {
        'mfussenegger/nvim-dap',
        ft = { 'python', 'go' },
        dependencies = {
            { 'mfussenegger/nvim-dap-python' },
            { 'leoluz/nvim-dap-go' },
            { 'igorlfs/nvim-dap-view' },
            { 'theHamsta/nvim-dap-virtual-text' },
        },
        config = function()
            require('dap-python').setup 'python3'
            require('dap-go').setup {}
            local dap = require 'dap'
            local dv = require 'dap-view'

            require('dap-view').setup {
                winbar = {
                    -- merge the integrated terminal (console) with other sections
                    sections = { 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl', 'console' },
                },
                windows = {
                    size = 0.33,
                },
            }

            dap.listeners.before.attach['dap-view-config'] = function()
                dv.open()
            end
            dap.listeners.before.launch['dap-view-config'] = function()
                dv.open()
            end
            dap.listeners.before.event_terminated['dap-view-config'] = function()
                dv.close()
            end
            dap.listeners.before.event_exited['dap-view-config'] = function()
                dv.close()
            end

            require('nvim-dap-virtual-text').setup {}

            if Milanglacier.fuzzy_finder == 'telescope' then
                if not pcall(require('telescope').load_extension, 'dap') then
                    vim.notify(
                        'Failed to load telescope dap extension. Please check your telescope installation and configuration.',
                        vim.log.levels.ERROR
                    )
                end
            end

            local opts = function(desc)
                return { noremap = true, desc = desc }
            end

            keymap('n', '<F5>', '<cmd>lua require"dap".continue()<CR>', opts 'dap continue')
            keymap('n', '<F6>', '<cmd>lua require"dap".pause()<CR>', opts 'dap pause')
            keymap('n', '<S-F5>', '<cmd>lua require"dap".close()<CR>', opts 'dap close')
            keymap('n', '<F8>', '<cmd>lua require"dap".run_to_cursor()<CR>', opts 'dap run to cursor')
            keymap('n', '<F9>', '<cmd>lua require"dap".toggle_breakpoint()<CR>', opts 'dap breakpoint')
            keymap(
                'n',
                '<S-F9>',
                "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
                opts 'dap conditional breakpoint'
            )
            keymap('n', '<F10>', '<cmd>lua require"dap".step_over()<CR>', opts 'dap step over')
            keymap('n', '<F11>', '<cmd>lua require"dap".step_into()<CR>', opts 'dap step into')
            keymap('n', '<S-F11>', '<cmd>lua require"dap".step_out()<CR>', opts 'dap step out')

            -- iterminal special keysequence
            keymap('n', '<F17>', '<cmd>lua require"dap".close()<CR>', opts 'dap close')
            keymap('n', '<F23>', '<cmd>lua require"dap".step_out()<CR>', opts 'dap step out')
            keymap(
                'n',
                '<F21>',
                "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
                opts 'dap conditional breakpoint'
            )

            -- dapview

            keymap('n', '<Leader>dt', '<cmd>DapViewToggle<CR>', opts 'dap view toggle')
            keymap('n', '<Leader>dw', '<cmd>DapViewWatch<CR>', opts 'dap view watch symbol under cursor')
            keymap('n', '<Leader>djr', '<cmd>DapViewJump repl<CR>', opts 'dap view jump to repl')
            keymap('n', '<Leader>djs', '<cmd>DapViewJump scopes<CR>', opts 'dap view jump to scopes')
            keymap('n', '<Leader>dje', '<cmd>DapViewJump exceptions<CR>', opts 'dap view jump to exceptions')
            keymap('n', '<Leader>djb', '<cmd>DapViewJump breakpoints<CR>', opts 'dap view jump to breakpoints')
            keymap('n', '<Leader>djw', '<cmd>DapViewJump watches<CR>', opts 'dap view jump to watches')
            keymap('n', '<Leader>djt', '<cmd>DapViewJump threads<CR>', opts 'dap view jump to threads')
            keymap('n', '<Leader>djc', '<cmd>DapViewJump console<CR>', opts 'dap view jump to console')

            -- telescope extensions

            keymap('n', '<Leader>dc', '<cmd>FF dap_commands<CR>', opts 'dap commands')
            keymap('n', '<Leader>dC', '<cmd>FF dap_configurations<CR>', opts 'dap configs')
            keymap('n', '<Leader>db', '<cmd>FF dap_breakpoints<CR>', opts 'dap list breakpoints')
            keymap('n', '<Leader>dv', '<cmd>FF dap_variables<CR>', opts 'dap variables')
            keymap('n', '<Leader>df', '<cmd>FF dap_frames<CR>', opts 'dap frames')

            vim.fn.sign_define('DapBreakpoint', { text = '', texhl = 'TodoFgFIX' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '', texhl = 'TodoFgFIX' })

            autocmd('FileType', {
                group = myaugroup,
                pattern = { 'dap-view', 'dap-repl', 'dap-view-term' },
                desc = 'set dapview keymap',
                callback = function()
                    bufmap(0, 'n', ']r', '<cmd>DapViewJump repl<CR>', opts 'dap view jump to repl')
                    bufmap(0, 'n', ']s', '<cmd>DapViewJump scopes<CR>', opts 'dap view jump to scopes')
                    bufmap(0, 'n', ']e', '<cmd>DapViewJump exceptions<CR>', opts 'dap view jump to exceptions')
                    bufmap(0, 'n', ']b', '<cmd>DapViewJump breakpoints<CR>', opts 'dap view jump to breakpoints')
                    bufmap(0, 'n', ']w', '<cmd>DapViewJump watches<CR>', opts 'dap view jump to watches')
                    bufmap(0, 'n', ']t', '<cmd>DapViewJump threads<CR>', opts 'dap view jump to threads')
                    bufmap(0, 'n', ']c', '<cmd>DapViewJump console<CR>', opts 'dap view jump to console')
                end,
            })
        end,
    },
}
