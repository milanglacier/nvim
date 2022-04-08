vim.cmd [[packadd! LuaSnip]]
vim.cmd [[packadd! friendly-snippets]]

require("luasnip.loaders.from_vscode").lazy_load({paths = {"~/.config/nvim/snippets"}})
require("luasnip.loaders.from_vscode").lazy_load()
