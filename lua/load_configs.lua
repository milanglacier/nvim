if not vim.g.vscode then
    require 'conf.builtin_extend'
    require 'conf.move_tabs'

    require 'conf.colorscheme'

    require 'conf.ui'
    require 'conf.mini'

    require 'conf.text_edit'
    require 'conf.cli_tools'

    require 'conf.langs'

    require 'conf.treesitter'

    require 'conf.utils'

    require 'conf.telescope'

    require 'conf.snippets'
    require 'conf.cmp'

    require 'conf.lspconfig'
    require 'conf.lsp_tools'

    require 'conf.dap'

    require 'conf.org'
else
    require 'conf.builtin_extend'
    require 'conf.text_edit'

    require 'conf.langs'

    require 'conf.treesitter'

    require 'conf.vscode'
end
