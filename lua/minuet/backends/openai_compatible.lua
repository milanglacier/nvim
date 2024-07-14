local config = require('minuet').config
local common = require 'minuet.backends.common'

local M = {}

local options = vim.deepcopy(config.provider_options.openai_compatible)

M.is_available = function()
    if options.end_point == '' or options.api_key == '' or options.name == '' then
        return false
    end

    if vim.env[options.api_key] == nil or vim.env[options.api_key] == '' then
        return false
    else
        return true
    end
end

if not M.is_available() then
    vim.notify('The provider specified as OpenAI compatible is not properly configured.', vim.log.levels.ERROR)
end

M.complete = function(context_before_cursor, context_after_cursor, callback)
    common.complete_openai_base(options, context_before_cursor, context_after_cursor, callback)
end

return M
