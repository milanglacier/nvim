local M = {}
local config = require('minuet').config

-- referenced from cmp_ai
function M.make_tmp_file(content)
    local tmp_file = os.tmpname()

    local f = io.open(tmp_file, 'w+')
    if f == nil then
        vim.notify('Cannot open temporary message file: ' .. tmp_file, vim.log.levels.ERROR)
        return
    end

    local result, json = pcall(vim.json.encode, content)

    if not result then
        vim.notify('Failed to encode completion request data', vim.log.levels.ERROR)
        return
    end

    f:write(json)
    f:close()

    return tmp_file
end

function M.add_language_comment()
    if vim.bo.ft == nil or vim.bo.ft == '' then
        return ''
    end

    if vim.bo.commentstring == nil or vim.bo.commentstring == '' then
        return '# language: ' .. vim.bo.ft
    end

    return string.format(vim.bo.commentstring, string.format('language: %s', vim.bo.ft))
end

function M.add_tab_comment()
    if vim.bo.ft == nil or vim.bo.ft == '' then
        return ''
    end

    local tab_comment

    if vim.bo.expandtab and vim.bo.softtabstop > 0 then
        tab_comment = 'indentation: use ' .. vim.bo.softtabstop .. ' spaces for a tab'

        if vim.bo.commentstring == nil or vim.bo.commentstring == '' then
            return '# ' .. tab_comment
        end

        return string.format(vim.bo.commentstring, tab_comment)
    end

    if not vim.bo.expandtab then
        tab_comment = 'indentation: use \t for a tab'
        if vim.bo.commentstring == nil or vim.bo.commentstring == '' then
            return '# ' .. tab_comment
        end

        return string.format(vim.bo.commentstring, tab_comment)
    end

    return ''
end

-- emulate the cmp context, use as testing purpose
function M.make_cmp_context()
    local self = {}
    local cursor = vim.api.nvim_win_get_cursor(0)
    self.cursor_line = vim.api.nvim_get_current_line()
    self.cursor = {}
    self.cursor.row = cursor[1]
    self.cursor.col = cursor[2] + 1
    self.cursor.line = self.cursor.row - 1
    self.cursor.character = require('cmp.utils.misc').to_utfindex(self.cursor_line, self.cursor.col)
    self.cursor_before_line = string.sub(self.cursor_line, 1, self.cursor.col - 1)
    self.cursor_after_line = string.sub(self.cursor_line, self.cursor.col)
    self.aborted = false
    return self
end

function M.get_context(cmp_context)
    local cursor = cmp_context.cursor
    local lines_before_list = vim.api.nvim_buf_get_lines(0, 0, cursor.line, false)
    local lines_after_list = vim.api.nvim_buf_get_lines(0, cursor.line + 1, -1, false)

    local lines_before = table.concat(lines_before_list, '\n')
    local lines_after = table.concat(lines_after_list, '\n')

    lines_before = lines_before .. '\n' .. cmp_context.cursor_before_line
    lines_after = cmp_context.cursor_after_line .. '\n' .. lines_after

    local n_chars_before = vim.fn.strchars(lines_before)
    local n_chars_after = vim.fn.strchars(lines_after)

    if n_chars_before + n_chars_after > config.context_window then
        -- use some heuristic to decide the context length of before cursor and after cursor
        if n_chars_before < config.context_window * 0.5 then
            -- at the very beginning of the file
            lines_after = vim.fn.strcharpart(lines_after, 0, config.context_window - n_chars_before)
        elseif n_chars_after < config.context_window * 0.5 then
            -- at the very end of the file
            lines_before = vim.fn.strcharpart(lines_before, n_chars_before + n_chars_after - config.context_window)
        else
            -- at the middle of the file, use the context_ratio to determine the allocation
            lines_after =
                vim.fn.strcharpart(lines_after, 0, math.floor(config.context_window * (1 - config.context_ratio)))

            lines_before = vim.fn.strcharpart(
                lines_before,
                n_chars_before - math.floor(config.context_window * config.context_ratio)
            )
        end
    end

    return {
        lines_before = lines_before,
        lines_after = lines_after,
    }
end

M.add_single_line_entry = function(list)
    local newlist = {}

    for _, item in ipairs(list) do
        if type(item) == 'string' then
            -- single line completion item should be preferred.
            table.insert(newlist, item)
            table.insert(newlist, 1, vim.split(item, '\n')[1])
        end
    end

    return newlist
end

--- dedup the items in a list
M.list_dedup = function(list)
    local hash = {}
    local items_cleaned = {}
    for _, item in ipairs(list) do
        if type(item) == 'string' and not hash[item] then
            hash[item] = true
            table.insert(items_cleaned, item)
        end
    end
    return items_cleaned
end

return M
