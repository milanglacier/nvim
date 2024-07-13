local config = require('minuet').config
local utils = require 'minuet.utils'
local job = require 'plenary.job'

local M = {}

M.is_available = function()
    if vim.env.ANTHROPIC_API_KEY == nil or vim.env.ANTHROPIC_API_KEY == '' then
        return false
    else
        return true
    end
end

if not M.is_available() then
    vim.notify('Anthropic API key is not set', vim.log.levels.ERROR)
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

    local messages = vim.deepcopy(config.provider_options.claude.few_shots)
    table.insert(messages, { role = 'user', content = context })

    local data = {
        model = config.provider_options.claude.model,
        system = config.provider_options.claude.system,
        max_tokens = config.provider_options.claude.max_tokens,
        stop_sequences = config.provider_options.claude.stop,
        messages = messages,
    }

    local data_file = utils.make_tmp_file(data)

    if data_file == nil then
        return
    end

    job:new({
        command = 'curl',
        args = {
            'https://api.anthropic.com/v1/messages',
            '-H',
            'Content-Type: application/json',
            '-H',
            'x-api-key: ' .. vim.env.ANTHROPIC_API_KEY,
            '-H',
            'anthropic-version: 2023-06-01',
            '--max-time',
            tostring(config.request_timeout),
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
                    vim.notify('Failed to parse Claude API response', vim.log.levels.INFO)
                end
                callback()
                return
            end

            if not json.content then
                if config.notify then
                    vim.notify('No response from Claude API', vim.log.levels.INFO)
                end
                callback()
                return
            end

            local items_raw = json.content[1].text

            success, items_raw = pcall(vim.split, items_raw, '<endCompletion>')
            if not success then
                if config.notify then
                    vim.notify('Failed to parse Claude response at content.text', vim.log.levels.INFO)
                end
                callback()
                return
            end

            local items = {}

            for _, item in ipairs(items_raw) do
                if item:find '%S' then -- only include entries that contains non-whitespace
                    -- replace the last \n charecter if it exists
                    item = item:gsub('\n$', '')
                    table.insert(items, item)
                end
            end

            callback(items)
        end),
    }):start()
end

return M
