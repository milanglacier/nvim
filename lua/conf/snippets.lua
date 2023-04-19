require('luasnip.loaders.from_vscode').lazy_load { paths = { vim.fn.stdpath 'config' .. '/snippets' } }
require('luasnip.loaders.from_vscode').lazy_load()
