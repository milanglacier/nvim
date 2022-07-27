vim.cmd.packadd { 'LuaSnip', bang = true }
vim.cmd.packadd { 'friendly-snippets', bang = true }

require('luasnip.loaders.from_vscode').lazy_load { paths = { '~/.config/nvim/snippets' } }
require('luasnip.loaders.from_vscode').lazy_load()
