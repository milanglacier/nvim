local keymap = vim.api.nvim_set_keymap

return {
    {
        'mfussenegger/nvim-dap',
        ft = { 'python', 'go' },
        dependencies = {
            { 'mfussenegger/nvim-dap-python' },
            { 'leoluz/nvim-dap-go' },
            { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
            { 'theHamsta/nvim-dap-virtual-text' },
        },
        config = function()
            require('dap-python').setup 'python3'
            require('dap-go').setup {}
            local dap = require 'dap'
            local dapui = require 'dapui'

            dapui.setup {
                layouts = {
                    {
                        elements = {
                            { id = 'breakpoints', size = 0.15 },
                            { id = 'stacks', size = 0.3 },
                            { id = 'watches', size = 0.25 },
                            { id = 'scopes', size = 0.3 },
                        },
                        position = 'right',
                        size = math.floor(vim.o.columns / 3),
                    },
                    {
                        elements = {
                            'repl',
                            'console',
                        },
                        size = math.floor(vim.o.lines / 5),
                        position = 'bottom',
                    },
                },
            }

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
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

            -- builtin dap ui

            keymap('n', '<Leader>dh', '<cmd>lua require("dap.ui.widgets").hover()<CR>', opts 'dap hover')
            keymap('n', '<Leader>dr', '<cmd>lua require("dap").repl.toggle()<CR>', opts 'dap repl')

            -- plugin dap ui

            keymap('n', '<Leader>du', '<cmd>lua require"dapui".toggle()<CR>', opts 'dap ui')

            -- telescope extensions

            keymap('n', '<Leader>dc', '<cmd>FF dap_commands<CR>', opts 'dap commands')
            keymap('n', '<Leader>dC', '<cmd>FF dap_configurations<CR>', opts 'dap configs')
            keymap('n', '<Leader>db', '<cmd>FF dap_breakpoints<CR>', opts 'dap list breakpoints')
            keymap('n', '<Leader>dv', '<cmd>FF dap_variables<CR>', opts 'dap variables')
            keymap('n', '<Leader>df', '<cmd>FF dap_frames<CR>', opts 'dap frames')

            vim.fn.sign_define('DapBreakpoint', { text = '', texhl = 'TodoFgFIX' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '', texhl = 'TodoFgFIX' })
        end,
    },
}
