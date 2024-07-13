local config = require('minuet').config
local utils = require 'minuet.utils'
local job = require 'plenary.job'

local M = {}

M.is_available = function()
    if vim.env.OPENAI_API_KEY == nil or vim.env.OPENAI_API_KEY == '' then
        return false
    else
        return true
    end
end

if not M.is_available() then
    vim.notify('OpenAI API key is not set', vim.log.levels.ERROR)
end

M.complete = function(context_before_cursor, context_after_cursor, callback)
    local language = utils.add_language_comment()
    local tab = utils.add_tab_comment()

    local context = language
        .. '\n'
        .. tab
        .. '\n'
        .. '<beginCode>'
        .. context_before_cursor
        .. '<cursorPosition>'
        .. context_after_cursor
        .. '<endCode>'

    local messages = vim.deepcopy(config.provider_options.openai.few_shots)
    table.insert(messages, 1, { role = 'system', content = config.provider_options.openai.system })
    table.insert(messages, { role = 'user', content = context })

    local data = {
        model = config.provider_options.openai.model,
        -- response_format = { type = 'json_object' }, -- NOTE: in practice this option yiled even worse result
        messages = messages,
    }

    local data_file = utils.make_tmp_file(data)

    if data_file == nil then
        return
    end

    job:new({
        command = 'curl',
        args = {
            'https://api.openai.com/v1/chat/completions',
            '-H',
            'Content-Type: application/json',
            '-H',
            'Authorization: Bearer ' .. vim.env.OPENAI_API_KEY,
            '--max-time',
            tostring(config.request_timeout),
            '-d',
            '@' .. data_file,
        },
        on_exit = vim.schedule_wrap(function(response, exit_code)
            local json = utils.json_decode(response, exit_code, data_file, 'OpenAI', callback)

            if not json then
                return
            end

            if not json.choices then
                if config.notify then
                    vim.notify('No response from OpenAI API', vim.log.levels.INFO)
                end
                callback()
                return
            end

            local items_raw = json.choices[1].message.content

            local items = utils.initial_process_completion_items(items_raw, 'OpenAI')

            callback(items)
        end),
    }):start()
end

return M
