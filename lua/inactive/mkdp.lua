vim.cmd [[packadd! markdown-preview.nvim]]

vim.g.mkdp_filetypes = { 'markdown.pandoc', 'markdown', 'rmd' }

local keymap = vim.api.nvim_set_keymap

keymap('n', '<LocalLeader>mp', ':MarkdownPreview<cr>', { noremap = true, silent = true })
keymap('n', '<LocalLeader>mq', ':MarkdownPreviewStop<cr>', { noremap = true, silent = true })
