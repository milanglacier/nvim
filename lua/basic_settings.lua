vim.o.modelines = 0
vim.o.compatible = false
vim.o.backspace = '2'

vim.o.writebackup = false
vim.o.backup = false

vim.g.skip_defaults_vim = 1

vim.o.exrc = true

vim.o.number = true
vim.o.autoindent = true
vim.o.softtabstop = 4
vim.o.tabstop = 4
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.showcmd = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.linebreak = true
vim.o.hidden = true
vim.o.laststatus = 3
vim.o.cmdheight = 0

vim.o.clipboard = 'unnamedplus'
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.wildoptions = 'pum,tagfile,fuzzy'

-- don't fold any text at startup
vim.o.foldmethod = 'indent'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- increase the frequency of CursorHold events trigger. Which is useful for
-- nvim-navic (winbar lsp symbol)
vim.o.updatetime = 2000

vim.g.mapleader = ' '
vim.g.maplocalleader = [[  ]]

vim.o.mouse = 'a'
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
vim.o.termguicolors = true
vim.opt.tags:append '.tags;' -- ; means upper search parent directory with .tags file

local gui_cursor = {
    'n-v-c:block',
    'i-ci-ve:ver10',
    'r-cr:hor20',
    'o:hor50',
    'a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor',
    'sm:block-blinkwait175-blinkoff150-blinkon175',
}

-- 'Sauce_Code_Pro_Nerd_Font_Complete:h15',
-- 'IntoneMono_Nerd_Font_Mono:h16',
-- 'SF_Mono_Regular:h15',
-- 'Space_Mono_Nerd_Font_Complete:h15',
-- 'Monego_Nerd_Font_Fix:h15',
-- 'CaskaydiaCove_Nerd_Font_Mono:h15',
vim.o.guifont = 'ComicShannsMono Nerd Font Mono:h15'
vim.o.guicursor = table.concat(gui_cursor, ',')

-- Configuration options for Neovim plugins
    completion_frontend = 'cmp',
    blink_use_main = false,
Milanglacier = {
}
