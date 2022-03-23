if vim.g.vscode then
    vim.g['sneak#label'] = 0
else
    vim.g['sneak#label'] = 1
end

vim.g['sneak#use_ic_scs'] = 1

local keymap = vim.api.nvim_set_keymap

keymap('', 'f', '<Plug>Sneak_f', {})
keymap('', 'F', '<Plug>Sneak_F', {})
keymap('', 't', '<Plug>Sneak_t', {})
keymap('', 'T', '<Plug>Sneak_T', {})
