local M = {}
M.load = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local command = vim.api.nvim_create_user_command
local bufmap = vim.api.nvim_buf_set_keymap
local bufcmd = vim.api.nvim_buf_create_user_command

function M.textobj_code_chunk(
    around_or_inner,
    start_pattern,
    end_pattern,
    has_same_start_end_pattern,
    is_in_visual_mode
)
    -- send `<ESC>` key to clear visual marks such that we can update the
    -- visual range.
    if is_in_visual_mode then
        vim.api.nvim_feedkeys('\27', 'nx', false)
    end

    local row = vim.api.nvim_win_get_cursor(0)[1]
    local max_row = vim.api.nvim_buf_line_count(0)

    -- nvim_buf_get_lines is 0 indexed, while nvim_win_get_cursor is 1 indexed
    local chunk_start = nil

    for row_idx = row, 1, -1 do
        local line_content = vim.api.nvim_buf_get_lines(0, row_idx - 1, row_idx, false)[1]

        -- upward searching if find the end_pattern first which means
        -- the cursor pos is not in a chunk, then early return
        -- this method only works when start and end pattern are not same
        if not has_same_start_end_pattern and line_content:match(end_pattern) then
            return
        end

        if line_content:match(start_pattern) then
            chunk_start = row_idx
            break
        end
    end

    -- if find chunk_start then find chunk_end
    local chunk_end = nil

    if chunk_start then
        if chunk_start == max_row then
            return
        end

        for row_idx = chunk_start + 1, max_row, 1 do
            local line_content = vim.api.nvim_buf_get_lines(0, row_idx - 1, row_idx, false)[1]

            if line_content:match(end_pattern) then
                chunk_end = row_idx
                break
            end
        end
    end

    if chunk_start and chunk_end then
        if around_or_inner == 'i' then
            vim.api.nvim_win_set_cursor(0, { chunk_start + 1, 0 })
            local internal_length = chunk_end - chunk_start - 2
            if internal_length == 0 then
                vim.cmd.normal { 'V', bang = true }
            elseif internal_length > 0 then
                vim.cmd.normal { 'V' .. internal_length .. 'j', bang = true }
            end
        end

        if around_or_inner == 'a' then
            vim.api.nvim_win_set_cursor(0, { chunk_start, 0 })
            local chunk_length = chunk_end - chunk_start
            vim.cmd.normal { 'V' .. chunk_length .. 'j', bang = true }
        end
    end
end

autocmd('FileType', {
    pattern = { 'rmd', 'quarto' },
    group = my_augroup,
    desc = 'set rmarkdown code chunk textobj',
    callback = function()
        bufmap(0, 'o', 'ac', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '```{.+}', '^```$')
            end,
        })
        bufmap(0, 'o', 'ic', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '```{.+}', '^```$')
            end,
        })

        bufmap(0, 'x', 'ac', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '```{.+}', '^```$', false, true)
            end,
        })

        bufmap(0, 'x', 'ic', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '```{.+}', '^```$', false, true)
            end,
        })
    end,
})

autocmd('FileType', {
    pattern = { 'r', 'python' },
    group = my_augroup,
    desc = 'set r, python code chunk textobj',
    callback = function()
        bufmap(0, 'o', 'a<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '^# ?%%%%.*', '^# ?%%%%.*', true)
                -- # %%xxxxx or #%%xxxx
            end,
        })
        bufmap(0, 'o', 'i<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '^# ?%%%%.*', '^# ?%%%%.*', true)
            end,
        })

        bufmap(0, 'x', 'a<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '^# ?%%%%.*', '^# ?%%%%.*', true, true)
            end,
        })

        bufmap(0, 'x', 'i<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '^# ?%%%%.*', '^# ?%%%%.*', true, true)
            end,
        })

        bufmap(0, 'o', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '# COMMAND ----------', '# COMMAND ----------', true)
            end,
        })
        bufmap(0, 'o', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '# COMMAND ----------', '# COMMAND ----------', true)
            end,
        })

        bufmap(0, 'x', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '# COMMAND ----------', '# COMMAND ----------', true, true)
            end,
        })

        bufmap(0, 'x', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '# COMMAND ----------', '# COMMAND ----------', true, true)
            end,
        })
    end,
})

autocmd('FileType', {
    pattern = { 'sql' },
    group = my_augroup,
    desc = 'set sql code chunk textobj',
    callback = function()
        bufmap(0, 'o', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '-- COMMAND ----------', '-- COMMAND ----------', true)
            end,
        })
        bufmap(0, 'o', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '-- COMMAND ----------', '-- COMMAND ----------', true)
            end,
        })

        bufmap(0, 'x', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '-- COMMAND ----------', '-- COMMAND ----------', true, true)
            end,
        })

        bufmap(0, 'x', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '-- COMMAND ----------', '-- COMMAND ----------', true, true)
            end,
        })
    end,
})

autocmd('FileType', {
    group = my_augroup,
    pattern = { 'r', 'rmd', 'quarto' },
    desc = 'set r, rmd, and quarto keyword pattern to include .',
    callback = function()
        vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
    end,
})

autocmd('FileType', {
    group = my_augroup,
    pattern = 'go',
    desc = 'set buffer opts for go',
    callback = function()
        vim.bo.expandtab = false
        -- go uses tab instead of spaces.
    end,
})

autocmd('FileType', {
    group = my_augroup,
    pattern = 'sql',
    desc = 'set commentstring for sql',
    callback = function()
        vim.bo.commentstring = '-- %s'
    end,
})

return M
