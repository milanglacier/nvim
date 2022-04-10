vim.cmd [[packadd! gitsigns.nvim]]
vim.cmd [[packadd! neogit]]
vim.cmd [[packadd! diffview.nvim]]

require('gitsigns').setup {
    current_line_blame = true,
    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
}
