local null_ls = require 'null-ls'
local cargo = '/Users/northyear/.cargo'

null_ls.setup {
    sources = {
        null_ls.builtins.formatting.stylua.with {
            command = cargo .. '/bin/stylua',
        },
        null_ls.builtins.diagnostics.selene.with {
            command = cargo .. '/bin/selene',
        },
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.proselint.with {
            command = vim.g.CONDA_PATHNAME .. '/bin/proselint',
            filetypes = {'markdown', 'markdown.pandoc', 'tex', 'rmd'}
        },
        null_ls.builtins.diagnostics.proselint.with {
            command = vim.g.CONDA_PATHNAME .. '/bin/proselint',
            filetypes = {'markdown', 'markdown.pandoc', 'tex', 'rmd'}
        },
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.diagnostics.codespell.with {
            command = vim.g.CONDA_PATHNAME .. '/bin/codespell',
            disabled_filetypes = { "NeogitCommitMessage" }
        },

    },
}
