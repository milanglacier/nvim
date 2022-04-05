local keymap = vim.api.nvim_set_keymap

keymap('i', 'jk', '<ESC>', { noremap = true })
keymap('t', 'jk', [[<C-\><C-n>]], { noremap = true })

vim.g.mapleader = ' '
keymap('', [[<Space><Space>]], [[<LocalLeader>]], {})

keymap('i', '<C-b>', '<Left>', { noremap = true })
keymap('i', '<C-p>', '<Up>', { noremap = true })
keymap('i', '<C-f>', '<Right>', { noremap = true })
keymap('i', '<C-n>', '<Down>', { noremap = true })
keymap('i', '<C-a>', '<home>', { noremap = true })
keymap('i', '<C-e>', '<end>', { noremap = true })
keymap('i', '<C-h>', '<BS>', { noremap = true })
keymap('i', '<C-k>', '<ESC>d$i', { noremap = true })

keymap('t', '<C-b>', '<Left>', { noremap = true })
keymap('t', '<C-p>', '<Up>', { noremap = true })
keymap('t', '<C-f>', '<Right>', { noremap = true })
keymap('t', '<C-n>', '<Down>', { noremap = true })
keymap('t', '<C-a>', '<home>', { noremap = true })
keymap('t', '<C-e>', '<end>', { noremap = true })
keymap('t', '<C-h>', '<BS>', { noremap = true })
keymap('t', '<C-k>', '<ESC>d$i', { noremap = true })

keymap('n', '<Leader>cd', [[:cd %:h<cr>]], { noremap = true })
keymap('n', '<Leader>cu', [[:cd ..<cr>]], { noremap = true })

keymap('n', ']b', [[:bn<cr>]], { noremap = true })
keymap('n', '[b', [[:bp<cr>]], { noremap = true })

keymap('n', '<Leader>to', [[:tabonly<cr>]], { noremap = true })
keymap('n', '<Leader>tn', [[:tabnew<cr>]], { noremap = true })
keymap('n', '<Leader>tc', [[:tabclose<cr>]], { noremap = true })

vim.cmd [[
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=400}
augroup END
]]

local M = {}

function M.ping_cursor()
    vim.o.cursorline = true
    vim.o.cursorcolumn = true

    vim.cmd 'redraw'
    vim.cmd 'sleep 1000m'

    vim.o.cursorline = false
    vim.o.cursorcolumn = false
end

keymap('n', '<Leader>pc', '<cmd>lua require("conf.builtin_extend").ping_cursor()<CR>', { noremap = true })

return M
