-- Add support for the LazyFile event
-- Copied from LazyVim
local Event = require 'lazy.core.handler.event'

Event.mappings.LazyFile = { id = 'LazyFile', event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' } }

Event.mappings['User LazyFile'] = Event.mappings.LazyFile

require('lazy').setup {
    spec = { import = 'plugins' },
    change_detection = {
        enabled = false,
    },
    defaults = {
        lazy = true,
    },
    pkg = {
        -- I don't use plugins that need complex build system, especially
        -- luarocks. The recent updates of lazy.nvim will build luarocks
        -- automatically if the plugin has luarocks spec.
        enabled = false,
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
