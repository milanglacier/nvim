local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local need_bootstrap = not vim.loop.fs_stat(lazypath)
if need_bootstrap then
    vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    }
end

vim.opt.rtp:prepend(lazypath)
vim.loader.enable()

require 'basic_settings'
require 'load_plugins'

if not need_bootstrap then
    require 'load_configs'
end
