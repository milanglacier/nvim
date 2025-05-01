local M = {}

local api = vim.api
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local command = vim.api.nvim_create_user_command
local bufmap = vim.api.nvim_buf_set_keymap

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

    vim.api.nvim_exec_autocmds('User', {
        pattern = 'CondaEnvActivate',
        data = { conda_env_path = conda_current_env_path },
    })

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

    vim.api.nvim_exec_autocmds('User', {
        pattern = 'CondaEnvDeactivate',
    })
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
            if success ~= 0 then
                vim.notify 'current project is not a poetry project or poetry is not installed!'
                return
            end

            if #poetry_envs == 1 then
                -- If only one environment, activate it directly
                local choice = poetry_envs[1]
                choice = string.gsub(choice, ' %(Activated%)$', '')
                vim.cmd.PyVenvActivate { args = { choice } }
                return
            end

            -- If multiple environments, show the selection UI
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

    vim.api.nvim_exec_autocmds('User', {
        pattern = 'PythonEnvActivate',
        data = { venv_path = vim.env.VIRTUAL_ENV },
    })

    vim.notify('Python venv activated: ' .. vim.env.VIRTUAL_ENV)
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

    vim.api.nvim_exec_autocmds('User', {
        pattern = 'PythonEnvDeactivate',
    })
end, {
    desc = 'This command deactivates a python venv.',
})

M.edit_src_wincmd = function(buf, orig_buf)
    local filename = vim.fn.fnamemodify(api.nvim_buf_get_name(orig_buf), ':t')
    local ft = api.nvim_get_option_value('filetype', { buf = buf })
    if ft == nil or ft == '' then
        ft = 'editsrc'
    end

    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        row = math.floor(vim.o.lines * 0.2),
        col = math.floor(vim.o.columns * 0.2),
        width = math.floor(vim.o.columns * 0.6),
        height = math.floor(vim.o.lines * 0.6),
        style = 'minimal',
        title = filename .. ':' .. ft,
        border = 'rounded',
        title_pos = 'center',
        zindex = 10, -- low priority
    })
end

local edit_src_guess_ft_functions = {
    function(content)
        if content:find '^%s*--sql' then
            return 'sql'
        elseif content:find '^%s*--SQL' then
            return 'sql'
        elseif content:find '^%s*/\\*.*sql.*\\*/' then
            return 'sql'
        elseif content:find '^%s*/\\*.*SQL.*\\*/' then
            return 'sql'
        else
            return nil
        end
    end,
    function(content)
        if content:find '^%s*# python' then
            return 'python'
        else
            return nil
        end
    end,
}

local function edit_src_commit_change(bufnr, orig_buf, start_row, start_col, end_row, end_col)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    vim.schedule(function()
        api.nvim_buf_set_text(orig_buf, start_row, start_col, end_row, end_col, lines)
    end)
    vim.cmd('bwipeout! ' .. bufnr)
end

local function edit_src_in_dedicated_buffer()
    local node = vim.treesitter.get_node()
    if not node then
        vim.notify 'not a valid treesitter node'
        return
    end

    if node:type() ~= 'string_content' then
        vim.notify 'not a string node'
        return
    end

    local orig_buf = api.nvim_get_current_buf()
    local content = vim.treesitter.get_node_text(node, 0)

    local start_row, start_col, end_row, end_col = node:range()
    local ft

    for _, func in ipairs(edit_src_guess_ft_functions) do
        ft = func(content)
        if ft then
            break
        end
    end

    -- NOTE: setting the buffer as non-scratch is to ensure lsp can be
    -- activated in the temp buffer, since lsp will not activate on scratch
    -- buffer.
    local buf = api.nvim_create_buf(true, false)
    if ft then
        api.nvim_set_option_value('filetype', ft, { buf = buf })
    end
    -- Setting buftype to nofile is to prevent from LSP complaining about it
    -- cannot find a file corresponding to the buffer.
    api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
    -- when the window is closed, destroy the temporary buffer
    -- automatically.
    api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

    api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n'))

    M.edit_src_wincmd(buf, orig_buf)

    bufmap(buf, 'n', '<LocalLeader>c', '', {
        desc = 'commit change to original file',
        callback = function()
            edit_src_commit_change(buf, orig_buf, start_row, start_col, end_row, end_col)
        end,
    })

    bufmap(buf, 'n', '<LocalLeader>k', '<cmd>bwipeout<cr>', {
        desc = 'discard change',
    })
end

autocmd('FileType', {
    pattern = 'python',
    group = my_augroup,
    desc = 'Add edit src keymap to python',
    callback = function()
        bufmap(0, 'n', "<LocalLeader>'", '', {
            desc = 'edit src under cursor in a dedicated buffer',
            callback = edit_src_in_dedicated_buffer,
        })
    end,
})

return M
