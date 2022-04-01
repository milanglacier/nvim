vim.g.textobj_between_no_default_key_mappings = 1
vim.g.textobj_chainmember_no_default_key_mappings = 1

local keymap = vim.api.nvim_set_keymap

keymap("x", "ab", "<Plug>(textobj-between-a)", {noremap = true, silent = true})
keymap("o", "ab", "<Plug>(textobj-between-a)", {noremap = true, silent = true})
keymap("x", "ib", "<Plug>(textobj-between-i)", {noremap = true, silent = true})
keymap("o", "ib", "<Plug>(textobj-between-i)", {noremap = true, silent = true})

keymap("x", "a.", "<Plug>(textobj-chainmember-a)", {noremap = true, silent = true})
keymap("o", "i.", "<Plug>(textobj-chainmember-i)", {noremap = true, silent = true})
keymap("x", "a.", "<Plug>(textobj-chainmember-a)", {noremap = true, silent = true})
keymap("o", "i.", "<Plug>(textobj-chainmember-i)", {noremap = true, silent = true})
