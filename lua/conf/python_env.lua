local M = {}

local command = vim.api.nvim_create_user_command

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
