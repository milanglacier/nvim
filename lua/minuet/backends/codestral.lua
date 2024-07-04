local config = require('minuet').config
local utils = require 'minuet.utils'
local job = require 'plenary.job'

local M = {}

M.is_available = function()
    if vim.env.CODESTRAL_API_KEY == nil or vim.env.CODESTRAL_API_KEY == '' then
        return false
    else
        return true
    end
end

if not M.is_available() then
    vim.notify('Codestral API key is not set', vim.log.levels.ERROR)
end

M.complete = function(context_before_cursor, context_after_cursor, callback)
    local language = utils.add_language_comment()
    local tab = utils.add_tab_comment()
    context_before_cursor = language .. '\n' .. tab .. '\n' .. context_before_cursor

    local data = {
        model = config.provider_options.codestral.model,
        prompt = context_before_cursor,
        suffix = context_after_cursor,
        max_tokens = config.provider_options.codestral.max_tokens,
        stop = config.provider_options.codestral.stop,
    }

    local data_file = utils.make_tmp_file(data)

    if data_file == nil then
        return
    end

    local items = {}
    local request_complete = 0
    local n_completions = config.provider_options.codestral.n_completions
    local has_called_back = false

    local function check_and_callback()
        if request_complete >= n_completions and not has_called_back then
            has_called_back = true
            callback(items)
        end
    end

    for _ = 1, n_completions do
        job:new({
            command = 'curl',
            args = {
                '-L',
                'https://codestral.mistral.ai/v1/fim/completions',
                '-H',
                'Content-Type: application/json',
                '-H',
                'Accept: application/json',
                '-H',
                'Authorization: Bearer ' .. vim.env.CODESTRAL_API_KEY,
                '--max-time',
                tostring(config.request_timeout),
                '-d',
                '@' .. data_file,
            },
            on_exit = vim.schedule_wrap(function(response, exit_code)
                -- Increment the request_send counter
                request_complete = request_complete + 1

                os.remove(data_file)

                if exit_code ~= 0 then
                    if config.notify then
                        vim.notify(string.format('Request failed with exit code %d', exit_code), vim.log.levels.ERROR)
                    end
                    check_and_callback()
                    return
                end

                local result = table.concat(response:result(), '\n')
                local success, json = pcall(vim.json.decode, result)
                if not success then
                    if config.notify then
                        vim.notify('Failed to parse Codestral API response', vim.log.levels.INFO)
                    end
                    check_and_callback()
                    return
                end

                if not json.choices then
                    if config.notify then
                        vim.notify('No response from Codestral API', vim.log.levels.INFO)
                    end
                    check_and_callback()
                    return
                end

                result = json.choices[1].message.content

                if type(result) ~= 'string' then
                    if config.notify then
                        vim.notify('Failed to parse Codestral response at choices.message.content', vim.log.levels.INFO)
                    end
                    check_and_callback()
                    return
                end

                table.insert(items, result)

                check_and_callback()
            end),
        }):start()
    end
end

return M
