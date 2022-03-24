vim.g.iron_map_defaults = 0
vim.g.iron_map_extended = 0

local iron = require("iron")
local mypath = require('bin_path')

iron.core.add_repl_definitions{
    r = {
        radian = {
            command = {mypath.radian},
        }
    },

    rmd = {
        radian = {
            command = {mypath.radian},
        }
    },
}

require('iron.fts.python').ipython.command = mypath.ipython

iron.core.set_config {
    preferred = {
        python = "ipython",
        r = 'radian',
        rmd = 'radian',
        clojure = "lein"
    },
    repl_open_cmd = require('iron.view').openwin("belowright 15 split"),
    buflisted = true,
}

local map = vim.api.nvim_set_keymap

map('n', '<localleader>rs', '<cmd>IronRepl<CR>', {})
map('n', '<localleader>rr', '<cmd>IronRestart<CR>', {})
map('n', '<localleader>ri', '<Plug>(iron-interupt)', {})
map('n', '<localleader>rc', '<Plug>(iron-clear)', {})
map('n', '<localleader>rq', '<Plug>(iron-exit)', {})

map('n', '<localleader>ss', '<Plug>(iron-send-line)', {})
map('n', '<localleader>s', '<Plug>(iron-send-motion)', {})
map('v', '<localleader>ss', '<Plug>(iron-visual-send)', {})
