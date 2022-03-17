vim.notify = require("notify")

require('notify').setup({
    max_width = 45,
    max_height = 20
})

require("telescope").load_extension("notify")
local opts = {noremap = true, silent=true}
vim.api.nvim_set_keymap('n', '<leader>fn', '<cmd>Telescope notify<cr>', opts)
