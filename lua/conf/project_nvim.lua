vim.cmd [[packadd! rooter.nvim]]
vim.cmd [[packadd! project.nvim]]

require("project_nvim").setup{}

vim.api.nvim_set_keymap('n', '<Leader>pj',
    '<cmd>Telescope projects<CR>', {noremap = true})
