local keymap = vim.api.nvim_set_keymap

local rm_trailing_space = function()
    vim.cmd [[%s/\s\+$//e]]
end

keymap('n', '<Leader>m<space>', '', {
    callback = rm_trailing_space,
    desc = 'Misc: remove trailing spaces',
})
