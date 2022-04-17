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

keymap('n', ']b', [[:bnext<cr>]], { noremap = true })
keymap('n', '[b', [[:bprevious<cr>]], { noremap = true })
keymap('n', ']q', [[:cnext<cr>]], { noremap = true })
keymap('n', '[q', [[:cprevious<cr>]], { noremap = true })

keymap('n', '<Leader>to', [[:tabonly<cr>]], { noremap = true })
keymap('n', '<Leader>tn', [[:tabnew<cr>]], { noremap = true })
keymap('n', '<Leader>tc', [[:tabclose<cr>]], { noremap = true })

local function dog() end
vim.keymap.set('n', '<Leader>dog', dog)

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local highlight_yanked_text = augroup('YankedTextHighlight', {})

autocmd('TextYankPost', {
    group = highlight_yanked_text,
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 400 }
    end,
    desc = 'highlight yanked text',
})

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
