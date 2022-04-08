vim.cmd [[packadd! iron.nvim]]

local iron = require 'iron'
local mypath = require 'bin_path'

vim.g.iron_map_defaults = 0
vim.g.iron_map_extended = 0

require('iron.fts.python').ipython.command = mypath.ipython
local extend = require("iron.util.tables").extend

local format = function(open, close, cr)
  return function(lines)
    if #lines == 1 then
      return { lines[1] .. cr }
    else
      local new = { open .. lines[1] }
      for line=2, #lines do
        table.insert(new, lines[line])
      end
      return extend(new, close)
    end
  end
end

iron.core.add_repl_definitions {
    r = {
        radian = {
            command = { mypath.radian },
            format = format("\27[200~", "\27[201~\13", "\13"),
        },
    },

    rmd = {
        radian = {
            command = { mypath.radian },
            format = format("\27[200~", "\27[201~\13", "\13"),
        },
    },
}

iron.core.set_config {
    preferred = {
        python = 'ipython',
        r = 'radian',
        rmd = 'radian',
        clojure = 'lein',
    },
    repl_open_cmd = require('iron.view').openwin 'belowright 15 split',
    buflisted = true,
}

local keymap = vim.api.nvim_set_keymap

keymap('n', '<localleader>rs', '<cmd>IronRepl<CR>', {})
keymap('n', '<localleader>rr', '<cmd>IronRestart<CR>', {})
keymap('n', '<localleader>ri', '<Plug>(iron-interupt)', {})
keymap('n', '<localleader>rc', '<Plug>(iron-clear)', {})
keymap('n', '<localleader>rq', '<Plug>(iron-exit)', {})

keymap('n', '<localleader>ss', '<Plug>(iron-send-line)', {})
keymap('n', '<localleader>s', '<Plug>(iron-send-motion)', {})
keymap('v', '<localleader>ss', '<Plug>(iron-visual-send)', {})
