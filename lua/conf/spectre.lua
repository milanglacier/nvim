require('spectre').setup()

vim.api.nvim_set_keymap('n', '<Leader>rg', "<cmd>lua require('spectre').open()<CR>", {noremap = true})
vim.api.nvim_set_keymap('v', '<Leader>rg', "<cmd>lua require('spectre').open_visual()<CR>", {noremap = true})

