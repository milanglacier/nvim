vim.cmd [[packadd! glow-hover.nvim]]

require('glow-hover').setup {
    max_width = 90,
    padding = 5,
    border = 'shadow',
    glow_path = 'glow',
}
