local default_config = require 'minuet.config'

local M = {}

function M.setup(config)
    M.config = vim.tbl_deep_extend('force', default_config, config or {})
    require('cmp').register_source('minuet', require('minuet.source'):new())
end

return M
