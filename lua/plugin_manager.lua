-- Add support for the LazyFile event
-- Copied from LazyVim
local Event = require 'lazy.core.handler.event'

Event.mappings.LazyFile = { id = 'LazyFile', event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' } }

Event.mappings['User LazyFile'] = Event.mappings.LazyFile

require('lazy').setup {
    spec = { import = 'plugins' },
    dev = {
        path = vim.env.HOME .. '/Desktop/personal-projects',
        patterns = { 'milanglacier' },
        fallback = true,
    },
    defaults = {
        lazy = true,
    },
    performance = {
        rtp = {
            disabled_plugins = {
                'gzip',
                'matchit',
                'matchparen',
                'netrwPlugin',
                'tarPlugin',
                'tohtml',
                'tutor',
                'zipPlugin',
            },
        },
    },
}
