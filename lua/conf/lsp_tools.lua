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
        close_behavior = 'close',
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
    saga.init_lsp_saga {
        code_action_lightbulb = {
            virtual_text = false,
        },
        move_in_saga = { prev = 'k', next = 'j' },
        finder_action_keys = {
            open = { 'o', '<cr>' },
            vsplit = 'v',
            split = 's',
            quit = { 'q', '<ESC>' },
            scroll_down = '<C-f>',
            scroll_up = '<C-b>',
            -- quit can be a table
        },
        code_action_keys = {
            quit = { 'q', '<ESC>' },
            exec = '<CR>',
        },
        rename_action_quit = '<ESC>',
        max_preview_lines = 100,
    }
end

M.load.glow_hover = function()
    vim.cmd [[packadd! glow-hover]]

    require('glow-hover').setup {
        max_width = 90,
        padding = 5,
        border = 'rounded',
        glow_path = 'glow',
    }
end

M.load.refactor = function()
    vim.cmd [[packadd! refactoring.nvim]]
    require('refactoring').setup {}
end

M.load.nullls = function()
    vim.cmd [[packadd! null-ls.nvim]]

    local null_ls = require 'null-ls'
    local mypath = require 'bin_path'

    null_ls.setup {
        sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.diagnostics.selene,
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.code_actions.proselint.with {
                filetypes = { 'markdown', 'markdown.pandoc', 'tex', 'rmd' },
            },
            null_ls.builtins.diagnostics.proselint.with {
                filetypes = { 'markdown', 'markdown.pandoc', 'tex', 'rmd' },
            },
            null_ls.builtins.code_actions.refactoring,
            null_ls.builtins.diagnostics.codespell.with {
                disabled_filetypes = { 'NeogitCommitMessage' },
            },
            null_ls.builtins.diagnostics.chktex,
            null_ls.builtins.formatting.prettierd.with {
                filetypes = { 'markdown.pandoc', 'json', 'markdown', 'rmd', 'yaml' },
            },
            null_ls.builtins.formatting.sqlfluff.with {
                args = { 'fix', '--dialect', 'mysql', '--disable_progress_bar', '-f', '-n', '-' },
            },
            null_ls.builtins.formatting.yapf.with {
                command = mypath.yapf,
                extra_args = { '--style={ column_limit: 120 }' },
            },
            null_ls.builtins.diagnostics.flake8.with {
                command = mypath.flake8,
                extra_args = { '--ignore', 'E501,W504,E126,E121' },
                -- ignore max line width, line break at binary operator
                -- ignore long line over-indented
            },
            -- null_ls.builtins.diagnostics.pylint.with {
            --     command = mypath.pylint,
            --     extra_args = {
            --         '--generated-members=torch.*,pt.*',
            --         '--disable=W0621,W0612,C0103,C0301,C0114,C0116,R0914,R0913,C0411,R0902',
            --     },
            --     -- ignore member checking for torch (and pt as an alias)
            --     -- ignore sneak_case naming style, line too long
            --     -- ignore redefine variable from outer scope
            --     -- ignore model doc string, ignore function doc string
            --     -- ignore too many local variables
            --     -- ignore too many arguments, too many instances attributes
            --     -- ignore standard import should be put before other import
            -- },
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
