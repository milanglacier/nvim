if not vim.g.vscode then
    require 'conf.builtin_extend'
    require 'conf.move_tabs'

    require 'conf.colorscheme'

    require 'conf.ui'
    require 'conf.mini'

    require 'conf.text_edit'
    require 'conf.cli_tools'

    require 'conf.treesitter'

    require 'conf.utils'

    require 'conf.telescope'

    require 'conf.snippets'
    require 'conf.cmp'

    require 'conf.lspconfig'
    require 'conf.lsp_tools'

    require 'conf.dap'

    require 'conf.org'

    if vim.g.started_by_firenvim then
        require 'conf.firenvim'
    end
else
    require 'conf.builtin_extend'
    require 'conf.text_edit'
    require 'conf.treesitter'

    require 'conf.vscode'
end
