vim.o.modelines = 0
vim.o.compatible = false
vim.o.backspace = '2'

vim.o.writebackup = false
vim.o.backup = false

vim.g.skip_defaults_vim = 1

vim.o.nu = true
vim.o.autoindent = true
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.showcmd = true
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.clipboard = 'unnamedplus'
vim.o.completeopt = 'menu,menuone,noselect'

vim.g.did_load_filetypes = 1

if not vim.g.vscode then
    vim.o.mouse = 'a'
    vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
    vim.o.termguicolors = true
    vim.o.guifont = 'Monaco_Nerd_Font_Complete:h15'
    vim.o.guicursor =
        [[n-v-c:block,i-ci-ve:ver70,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175]]
end
