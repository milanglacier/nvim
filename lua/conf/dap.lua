local mypath = require 'bin_path'

require('dap-python').setup(mypath.python)

require('dapui').setup {

    sidebar = {

        elements = {
            { id = 'breakpoints', size = 0.15 },
            { id = 'stacks', size = 0.3 },
            { id = 'watches', size = 0.25 },
            { id = 'scopes', size = 0.3 },
        },

        position = 'right',
    },

    tray = { elements = { nil }, size = 0 },
}

local opts = { noremap = true }

require('nvim-dap-virtual-text').setup()

vim.api.nvim_set_keymap('n', '<F5>', '<cmd>lua require"dap".continue()<CR>', opts)

vim.api.nvim_set_keymap('n', '<F6>', '<cmd>lua require"dap".pause()<CR>', opts)

vim.api.nvim_set_keymap('n', '<S-F5>', '<cmd>lua require"dap".close()<CR>', opts)

vim.api.nvim_set_keymap('n', '<F8>', '<cmd>lua require"dap".run_to_cursor()<CR>', opts)

vim.api.nvim_set_keymap('n', '<F9>', '<cmd>lua require"dap".toggle_breakpoint()<CR>', opts)

vim.api.nvim_set_keymap('n', '<F10>', '<cmd>lua require"dap".step_over()<CR>', opts)

vim.api.nvim_set_keymap('n', '<F11>', '<cmd>lua require"dap".step_into()<CR>', opts)

vim.api.nvim_set_keymap('n', '<S-F11>', '<cmd>lua require"dap".step_out()<CR>', opts)

vim.api.nvim_set_keymap('n', '<F9>', '<cmd>lua require"dap".toggle_breakpoint()<CR>', opts)

-- builtin dap ui

vim.api.nvim_set_keymap('n', '<Leader>dh', '<cmd>lua require("dap.ui.widgets").hover()<CR>', opts)

vim.api.nvim_set_keymap('n', '<Leader>dr', '<cmd>lua require("dap").repl.toggle()<CR>', opts)

-- plugin dap ui

vim.api.nvim_set_keymap('n', '<Leader>dui', '<cmd>lua require"dapui".toggle()<CR>', opts)

-- telescope extensions

vim.api.nvim_set_keymap('n', '<Leader>dk', '<cmd>lua require"telescope".extensions.dap.commands{}<CR>', opts)

vim.api.nvim_set_keymap('n', '<Leader>dc', '<cmd>lua require"telescope".extensions.dap.configurations{}<CR>', opts)

vim.api.nvim_set_keymap('n', '<Leader>db', '<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>', opts)

vim.api.nvim_set_keymap('n', '<Leader>dv', '<cmd>lua require"telescope".extensions.dap.variables{}<CR>', opts)

vim.api.nvim_set_keymap('n', '<Leader>df', '<cmd>lua require"telescope".extensions.dap.frames{}<CR>', opts)

vim.fn.sign_define('DapBreakpoint', { text = '', texhl = 'TodoFgFIX' })
