local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap
local my_augroup = require('conf.builtin_extend').my_augroup

local did_load_dap = false

local function load_dap()
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

    dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
    end

    local opts = function(desc)
        return { noremap = true, desc = desc }
    end

    require('nvim-dap-virtual-text').setup()
    require('telescope').load_extension 'dap'

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

    keymap('n', '<Leader>dc', '<cmd>lua require"telescope".extensions.dap.commands{}<CR>', opts 'dap commands')
    keymap('n', '<Leader>dC', '<cmd>lua require"telescope".extensions.dap.configurations{}<CR>', opts 'dap configs')
    keymap(
        'n',
        '<Leader>db',
        '<cmd>lua require"telescope".extensions.dap.list_breakpoints{}<CR>',
        opts 'dap list breakpoints'
    )
    keymap('n', '<Leader>dv', '<cmd>lua require"telescope".extensions.dap.variables{}<CR>', opts 'dap variables')
    keymap('n', '<Leader>df', '<cmd>lua require"telescope".extensions.dap.frames{}<CR>', opts 'dap frames')

    vim.fn.sign_define('DapBreakpoint', { text = '', texhl = 'TodoFgFIX' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '', texhl = 'TodoFgFIX' })

    local emmykeymap = require('conf.builtin_extend').emmykeymap

    emmykeymap('n', '(dapui-expand)', '<CR>')
    emmykeymap('n', '(dapui-open)', 'o')
    emmykeymap('n', '(dapui-remove)', 'd')
    emmykeymap('n', '(dapui-edit)', 'e')
    emmykeymap('n', '(dapui-repl)', 'r')
    emmykeymap('n', '(dapui-toggle)', 't')
end

autocmd('FileType', {
    pattern = { 'python', 'go' },
    once = true,
    group = my_augroup,
    callback = function()
        if not did_load_dap then
            did_load_dap = true
            load_dap()
        end
    end,
})
