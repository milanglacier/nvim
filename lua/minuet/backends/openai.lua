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

    local data = {
        model = config.provider_options.openai.model,
        -- response_format = { type = 'json_object' }, -- NOTE: in practice this option yiled even worse result
        messages = {
            { role = 'system', content = config.provider_options.openai.system },
            { role = 'user', content = context },
        },
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
            config.request_timeout,
            '-d',
            '@' .. data_file,
        },
        on_exit = vim.schedule_wrap(function(response, exit_code)
            os.remove(data_file)
            if exit_code ~= 0 then
                if config.notify then
                    vim.notify(string.format('Request failed with exit code %d', exit_code), vim.log.levels.ERROR)
                end
                callback()
                return
            end

            local result = table.concat(response:result(), '\n')
            local success, json = pcall(vim.json.decode, result)
            if not success then
                if config.notify then
                    vim.notify('Failed to parse OpenAI API response', vim.log.levels.INFO)
                end
                callback()
                return
            end

            if not json.choices then
                if config.notify then
                    vim.notify('No response from OpenAI API', vim.log.levels.INFO)
                end
                callback()
                return
            end

            local items_raw

            success, items_raw = pcall(vim.json.decode, json.choices[1].message.content)
            if not success then
                if config.notify then
                    vim.notify('Failed to parse OpenAI response at choices.message.content', vim.log.levels.INFO)
                end
                callback()
                return
            end

            if not vim.islist(items_raw) then
                if config.notify then
                    vim.notify('Failed to parse OpenAI response content as a list', vim.log.levels.INFO)
                end
                callback()
                return
            end

            local items = {}

            for _, item in ipairs(items_raw) do
                local completion_string
                success, completion_string = pcall(table.concat, item, '\n')
                if success then
                    table.insert(items, completion_string)
                end
            end

            callback(items)
        end),
    }):start()
end

return M
