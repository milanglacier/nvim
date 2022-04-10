require("substitute").setup()

local keymap = vim.api.nvim_set_keymap

keymap("n", "gs", "<cmd>lua require('substitute').operator()<cr>", { noremap = true })
keymap("n", "gss", "<cmd>lua require('substitute').line()<cr>", { noremap = true })
keymap("n", "gS", "<cmd>lua require('substitute').eol()<cr>", { noremap = true })
keymap("x", "gs", "<cmd>lua require('substitute').visual()<cr>", { noremap = true })
