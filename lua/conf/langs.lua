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

command('CondaActivateEnv', function(options)
    if vim.fn.executable 'conda' == 0 then
        vim.notify 'conda not found'
        return
    end

    vim.cmd.CondaDeactivate()

    local conda_info = vim.json.decode(vim.fn.system 'conda info --json')
    M.conda_info = conda_info

    local conda_current_env_path

    if options.args ~= nil and options.args ~= '' then
        conda_current_env_path = options.args
    else
        conda_current_env_path = conda_info.root_prefix
    end

    -- if conda_current_env_path is found in $PATH, do nothing, else prepend it to $PATH
    if not string.find(vim.env.PATH, conda_current_env_path .. '/bin') then
        vim.env.PATH = conda_current_env_path .. '/bin:' .. vim.env.PATH
    end

    vim.env.CONDA_PREFIX = conda_current_env_path
    vim.env.CONDA_DEFAULT_ENV = vim.fn.fnamemodify(conda_current_env_path, ':t')
    vim.env.CONDA_SHLVL = 1
    vim.env.CONDA_PROMPT_MODIFIER = '(' .. vim.env.CONDA_DEFAULT_ENV .. ') '

    vim.notify 'conda env activated'
end, {
    nargs = '?',
    complete = function(_, _, _)
        if vim.fn.executable 'conda' == 0 then
            return {}
        end

        local conda_envs

        -- use cache to speed up completion
        if M.conda_info then
            conda_envs = M.conda_info.envs
        else
            M.conda_info = vim.json.decode(vim.fn.system 'conda info --json')
            conda_envs = M.conda_info.envs
        end

        return conda_envs
    end,
})

command('CondaDeactivate', function(_)
    if vim.fn.executable 'conda' == 0 then
        vim.notify 'conda not found'
        return
    end

    local conda_info = vim.json.decode(vim.fn.system 'conda info --json')
    local conda_current_env_path = conda_info.default_prefix

    local env_split = vim.split(vim.env.PATH, ':')
    for idx, path in ipairs(env_split) do
        if path == conda_current_env_path .. '/bin' then
            table.remove(env_split, idx)
        end
    end
    vim.env.PATH = table.concat(env_split, ':')
    vim.env.CONDA_PREFIX = nil
    vim.env.CONDA_DEFAULT_ENV = nil
    vim.env.CONDA_SHLVL = 0
    vim.env.CONDA_PROMPT_MODIFIER = nil

    vim.notify 'conda env deactivated'
end, {
    desc = [[This command deactivates a conda environment. Note that after the
execution, the conda env will be completely cleared (i.e. without base
environment activated).]],
})

command('PoetryEnvActivate', function()
    local poetry_envs

    vim.fn.jobstart('poetry env list --full-path', {
        stdout_buffered = true,
        on_stdout = function(_, out, _)
            poetry_envs = vim.tbl_filter(function(x)
                return x ~= ''
            end, out)
        end,
        on_exit = function(_, success, _)
            if success == 0 then
                vim.ui.select(poetry_envs, {
                    prompt = 'select a poetry env',
                    format_item = function(x)
                        return vim.fn.fnamemodify(x, ':t')
                    end,
                }, function(choice)
                    if choice ~= nil then
                        choice = string.gsub(choice, ' %(Activated%)$', '')
                        vim.cmd.PyVenvActivate { args = { choice } }
                    end
                end)
            else
                vim.notify 'current project is not a poetry project or poetry is not installed!'
            end
        end,
    })
end, {
    desc = [[This command finds the current poetry venvs by using `poetry env list` command and activate the env selected by the user.]],
})

command('PoetryEnvDeactivate', function()
    vim.cmd.PyVenvDeactivate()
end, {
    desc = [[This command finds the current poetry venvs by using `poetry env list` command and activate the env selected by the user.]],
})

command('PyVenvActivate', function(options)
    vim.cmd.PyVenvDeactivate()
    local path = options.args
    path = vim.fn.fnamemodify(path, ':p:h')
    -- get the absolute path, and remove the trailing "/"
    path = string.gsub(path, '/bin$', '')
    -- remove the trailing '/bin'
    vim.env.VIRTUAL_ENV = path
    path = path .. '/bin'
    -- remove the trailing `/` in the string.
    vim.env.PATH = path .. ':' .. vim.env.PATH
end, {
    nargs = 1,
    complete = 'dir',
    desc = [[This command activates a python venv. The path to the python virtual environment may include "/bin/" or not.]],
})

command('PyVenvDeactivate', function(_)
    if vim.env.VIRTUAL_ENV == nil or vim.env.VIRTUAL_ENV == '' then
        return
    end
    local env_split = vim.split(vim.env.PATH, ':')
    for idx, path in ipairs(env_split) do
        if path == vim.env.VIRTUAL_ENV .. '/bin' then
            table.remove(env_split, idx)
        end
    end
    vim.env.PATH = table.concat(env_split, ':')
    vim.env.VIRTUAL_ENV = nil
end, {
    desc = 'This command deactivates a python venv.',
})

autocmd('FileType', {
    desc = 'set command for rendering rmarkdown',
    pattern = 'rmd',
    group = my_augroup,
    callback = function()
        bufcmd(0, 'RenderRmd', function(options)
            local winid = vim.api.nvim_get_current_win()
            ---@diagnostic disable-next-line: missing-parameter
            local current_file = vim.fn.expand '%:.' -- relative path to current wd
            current_file = vim.fn.shellescape(current_file)

            local cmd = string.format([[R --quiet -e "rmarkdown::render(%s)"]], current_file)
            local term_id = options.args ~= '' and tonumber(options.args) or nil

            ---@diagnostic disable-next-line: missing-parameter
            require('toggleterm').exec(cmd, term_id)
            vim.cmd.normal { 'G', bang = true }
            vim.api.nvim_set_current_win(winid)
        end, {
            nargs = '?', -- 0 or 1 arg
        })
    end,
})

autocmd('FileType', {
    desc = 'set command for rendering quarto',
    pattern = 'quarto',
    group = my_augroup,
    callback = function()
        bufcmd(0, 'RenderQuarto', function(options)
            local winid = vim.api.nvim_get_current_win()
            ---@diagnostic disable-next-line: missing-parameter
            local current_file = vim.fn.expand '%:.' -- relative path to current wd
            current_file = vim.fn.shellescape(current_file)

            local cmd = string.format([[quarto render %s]], current_file)
            local term_id = options.args ~= '' and tonumber(options.args) or nil

            ---@diagnostic disable-next-line: missing-parameter
            require('toggleterm').exec(cmd, term_id)
            vim.cmd.normal { 'G', bang = true }
            vim.api.nvim_set_current_win(winid)
        end, {
            nargs = '?', -- 0 or 1 arg
        })

        bufcmd(0, 'PreviewQuarto', function(options)
            local winid = vim.api.nvim_get_current_win()
            ---@diagnostic disable-next-line: missing-parameter
            local current_file = vim.fn.expand '%:.' -- relative path to current wd
            current_file = vim.fn.shellescape(current_file)

            local cmd = string.format([[quarto preview %s]], current_file)
            local term_id = options.args ~= '' and tonumber(options.args) or nil

            ---@diagnostic disable-next-line: missing-parameter
            require('toggleterm').exec(cmd, term_id)
            vim.cmd.normal { 'G', bang = true }
            vim.api.nvim_set_current_win(winid)
        end, {
            nargs = '?', -- 0 or 1 arg
        })
    end,
})

return M
