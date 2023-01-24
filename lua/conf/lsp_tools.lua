local M = {}
M.load = {}
local bufmap = vim.api.nvim_buf_set_keymap

M.load.lspkind = function()
    require('lspkind').init {
        mode = 'symbol_text',
        symbol_map = {
            Number = '',
            Array = '',
            Variable = '',
            Method = 'ƒ',
            Function = '',
            Property = '',
            Boolean = '⊨',
            Namespace = '',
            Package = '',
        },
    }
end

M.signature = function(bufnr)
    require('lsp_signature').on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
            border = 'double',
        },
        floating_window = false,
        toggle_key = '<A-x>',
        floating_window_off_x = 15, -- adjust float windows x position.
        floating_window_off_y = 15,
        hint_enable = false,
        -- hint_prefix = "",
        -- doc_lines = 5,
        time_interval = 100,
    }, bufnr)
end

M.load.aerial = function()
    require('aerial').setup {
        backends = { 'lsp', 'treesitter', 'markdown' },
        close_automatic_events = { 'unsupported' },
        default_bindings = true,
        filter_kind = false,
        on_attach = function(bufnr)
            bufmap(bufnr, 'n', '<leader>lo', '<cmd>AerialToggle!<CR>', {
                desc = 'lsp symbol outline',
            })
        end,
    }
end

M.load.lspsaga = function()
    local saga = require 'lspsaga'
    saga.setup {
        lightbulb = {
            sign = false,
            virtual_text = true,
        },
        finder = {
            open = { 'o', '<cr>' },
            vsplit = 'v',
            split = 's',
            quit = { 'q', '<ESC>' },
            scroll_down = '<C-f>',
            scroll_up = '<C-b>',
        },
        code_action = {
            keys = {
                quit = '<ESC>',
                exec = '<CR>',
            },
        },
        rename = {
            quit = '<ESC>',
            in_select = false,
        },
        diagnostic = {
            keys = {
                exec_action = '<CR>',
            },
        },
        ui = {
            border = 'rounded',
        },
        symbol_in_winbar = {
            enable = false,
        },
    }
end

M.original_hover_handler = vim.lsp.handlers['textDocument/hover']

M.load.glow_hover = function()
    vim.cmd.packadd { 'glow-hover', bang = true }

    require('glow-hover').setup {
        max_width = 90,
        padding = 5,
        border = 'rounded',
        glow_path = 'glow',
    }
end

M.load.refactor = function()
    vim.cmd.packadd { 'refactoring.nvim', bang = true }
    require('refactoring').setup {}
end

M.load.nullls = function()
    vim.cmd.packadd { 'null-ls.nvim', bang = true }

    local null_ls = require 'null-ls'
    local util = require 'null-ls.utils'

    local function root_pattern_wrapper(patterns)
        return function()
            return util.root_pattern('.git', unpack(patterns or {}))(vim.fn.expand '%:p')
        end
    end

    local function source_wrapper(args)
        local source = args[1]
        local patterns = args[2]
        args[1] = nil
        args[2] = nil
        args.cwd = args.cwd or root_pattern_wrapper(patterns)
        return source.with(args)
    end

    null_ls.setup {
        fallback_severity = vim.diagnostic.severity.INFO,
        sources = {
            source_wrapper { null_ls.builtins.formatting.stylua },
            source_wrapper { null_ls.builtins.diagnostics.selene },
            source_wrapper { null_ls.builtins.code_actions.gitsigns },
            source_wrapper { null_ls.builtins.code_actions.refactoring },
            source_wrapper {
                null_ls.builtins.formatting.prettierd,
                filetypes = { 'markdown.pandoc', 'json', 'markdown', 'rmd', 'yaml', 'quarto' },
            },
            source_wrapper {
                null_ls.builtins.formatting.sqlfluff,
                extra_args = { '--dialect', 'mysql' },
            },
            source_wrapper {
                null_ls.builtins.formatting.yapf,
                { 'pyproject.toml' },
            },
            source_wrapper {
                null_ls.builtins.diagnostics.flake8,
                { 'pyproject.toml' },
            },
        },
    }
end

M.load.aerial()
M.load.glow_hover()
M.load.lspkind()
M.load.lspsaga()
M.load.refactor()
M.load.nullls()

return M
