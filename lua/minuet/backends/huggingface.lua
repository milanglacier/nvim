local config = require('minuet').config
local utils = require 'minuet.utils'
local job = require 'plenary.job'
local options = vim.deepcopy(require('minuet.config').provider_options.huggingface)

local stops = {}

for _, token in ipairs(options.stop or {}) do
    table.insert(stops, token)
end

for _, token in ipairs(options.strategies.completion.stop or {}) do
    table.insert(stops, token)
end

local M = {}

M.is_available = function()
    if vim.env.HF_API_KEY == nil or vim.env.HF_API_KEY == '' then
        return false
    else
        return true
    end
end

if not M.is_available() then
    vim.notify('Huggingface API key is not set', vim.log.levels.ERROR)
end

M.complete_completion = function(context_before_cursor, context_after_cursor, callback)
    local language = utils.add_language_comment()
    local tab = utils.add_tab_comment()

    local inputs
    local markers = options.strategies.completion.markers

    if options.strategies.completion.strategy == 'PSM' then
        inputs = markers.prefix
            .. language
            .. '\n'
            .. tab
            .. '\n'
            .. context_before_cursor
            .. markers.suffix
            .. context_after_cursor
            .. markers.middle
    elseif options.strategies.completion.strategy == 'SPM' then
        inputs = markers.suffix
            .. context_after_cursor
            .. markers.prefix
            .. language
            .. '\n'
            .. tab
            .. '\n'
            .. context_before_cursor
            .. markers.middle
    elseif options.strategies.completion.strategy == 'PM' then
        inputs = markers.prefix .. language .. '\n' .. tab .. '\n' .. context_before_cursor .. markers.middle
    else
        vim.notify('huggingface: Unknown completion strategy', vim.log.levels.ERROR)
        return
    end

    local data = {
        inputs = inputs,
        parameters = {
            return_full_text = false,
            stop = stops,
            max_new_tokens = options.max_tokens,
            num_return_sequences = options.n_completions,
        },
        options = {
            use_cache = false,
        },
    }

    local data_file = utils.make_tmp_file(data)

    if data_file == nil then
        return
    end

    job:new({
        command = 'curl',
        args = {
            '-L',
            options.end_point,
            '-H',
            'Content-Type: application/json',
            '-H',
            'Accept: application/json',
            '-H',
            'Authorization: Bearer ' .. vim.env.HF_API_KEY,
            '--max-time',
            tostring(config.request_timeout),
            '-d',
            '@' .. data_file,
        },
        on_exit = vim.schedule_wrap(function(response, exit_code)
            local json = utils.json_decode(response, exit_code, data_file, 'huggingface', callback)

            if not json then
                return
            end

            local items = {}

            for _, item in ipairs(json) do
                if item.generated_text then
                    table.insert(items, item.generated_text)
                end
            end

            callback(items)
        end),
    }):start()
end

M.complete = function(context_before_cursor, context_after_cursor, callback)
    if options.type == 'completion' then
        M.complete_completion(context_before_cursor, context_after_cursor, callback)
    else
        vim.notify('huggingface: Unknown type', vim.log.levels.ERROR)
    end
end

return M
