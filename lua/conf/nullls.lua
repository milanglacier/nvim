local null_ls = require 'null-ls'
local mypath = require 'bin_path'

null_ls.setup {
    sources = {
        null_ls.builtins.formatting.stylua.with {
            command = mypath.stylua,
        },
        null_ls.builtins.diagnostics.selene.with {
            command = mypath.selene,
        },
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.proselint.with {
            command = mypath.proselint,
            filetypes = { 'markdown', 'markdown.pandoc', 'tex', 'rmd' },
        },
        null_ls.builtins.diagnostics.proselint.with {
            command = mypath.proselint,
            filetypes = { 'markdown', 'markdown.pandoc', 'tex', 'rmd' },
        },
        null_ls.builtins.code_actions.refactoring,
        null_ls.builtins.diagnostics.codespell.with {
            command = mypath.codespell,
            disabled_filetypes = { 'NeogitCommitMessage' },
        },
        null_ls.builtins.diagnostics.chktex,
        null_ls.builtins.formatting.prettierd.with {
            filetypes = { 'markdown.pandoc', 'json', 'markdown', 'rmd', 'yaml' },
        },
    },
}
