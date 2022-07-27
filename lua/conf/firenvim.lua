vim.cmd [[packadd! firenvim]]

vim.g.firenvim_config = {
    localSettings = {
        ['.*'] = {
            filename = '{hostname}_{pathname%32}.{extension}',
        },
    },
}

vim.o.swapfile = false
vim.o.number = false
vim.o.guifont = 'Monaco_Nerd_Font_Complete:h21'
vim.o.guicursor = 'n-v-c-sm:block,i-ci-ve:ver100,r-cr-o:hor20'

vim.cmd.packadd 'rose-pine'
require('rose-pine').setup {
    disable_italics = true,
}
local hour = os.date('*t').hour
vim.o.background = (hour <= 7 or hour >= 23) and 'dark' or 'light'
vim.cmd.colorscheme 'rose-pine'

vim.diagnostic.config {
    virtual_text = false,
}

require('cmp').setup.cmdline(':', {
    enabled = false,
})
require('mini.starter').setup {
    autoopen = false,
}
require('lualine').setup {
    options = {
        icons_enabled = false,
        component_separators = { left = '|', right = '|' },
        section_separators = { left = '|', right = '|' },
    },
    sections = {
        lualine_c = { 'filename' },
        lualine_x = {
            { 'filetype', icon = { '^' } },
        },
    },
}

if vim.api.nvim_win_get_height(0) <= 5 then
    require('cmp').setup {
        enabled = false,
    }
end

local autocmd = vim.api.nvim_create_autocmd

autocmd('BufEnter', {
    group = require('conf.builtin_extend').my_augroup,
    pattern = '*leetcode.cn_*',
    desc = 'set ft as python for leetcode',
    command = 'set filetype=python',
})
