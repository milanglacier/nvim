vim.cmd [[packadd! nvim-spectre]]

require('spectre').setup()

local keymap = vim.api.nvim_set_keymap

keymap('n', '<Leader>rg', "<cmd>lua require('spectre').open()<CR>", {noremap = true})
keymap('v', '<Leader>rg', "<cmd>lua require('spectre').open_visual()<CR>", {noremap = true})
