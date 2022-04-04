if not vim.g.vscode then

    require 'conf.impatient'

    require 'conf.builtin_extend'
    require 'conf.move_tabs'

    require 'conf.better_escape'

    require 'conf.colorscheme'

    require 'conf.lualine'
    require 'conf.notify'
    require 'conf.luatab'
    require 'conf.mini'

    require 'conf.autopairs'
    require 'conf.comment'
    require 'conf.dsf'
    require 'conf.substitute'
    require 'conf.targets'
    require 'conf.matchup'
    require 'conf.sneak'
    require 'conf.textobj'

    require 'conf.pandoc'

    require 'conf.treesitter'

    require 'conf.nvim_tree'

    require 'conf.telescope'
    require 'conf.project_nvim'

    require 'conf.lspkind'
    require 'conf.aerial'

    require 'conf.cmp'
    require 'conf.saga'
    require 'conf.lspconfig'
    require 'conf.signature'
    require 'conf.nullls'
    require 'conf.refactor'

    require 'conf.iron'

    require 'conf.mkdp'

    require 'conf.terminal'
    require 'conf.snippets'

    require 'conf.dap'
    require 'conf.spectre'
    require 'conf.gitsigns'

else

    require 'conf.impatient'

    require 'conf.builtin_extend'

    require 'conf.comment'
    require 'conf.dsf'
    require 'conf.substitute'
    require 'conf.targets'
    require 'conf.matchup'
    require 'conf.sneak'
    require 'conf.textobj'

    require 'conf.treesitter'
end
