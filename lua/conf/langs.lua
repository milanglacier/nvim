local M = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
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
    pattern = { 'nix' },
    desc = 'set nix keyword pattern to include -',
    callback = function()
        vim.bo.iskeyword = vim.bo.iskeyword .. ',-'
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

autocmd('FileType', {
    group = my_augroup,
    pattern = 'sql',
    desc = 'disable sql omnifunc',
    callback = function()
        -- avoid the following error: SQLComplete:The dbext plugin must be
        -- loaded for dynamic SQL completion
        vim.bo.omnifunc = vim.NIL
    end,
})

-- Language servers that read the interpreter from `python.pythonPath` and
-- reload it on `workspace/didChangeConfiguration`.
local lsps_supporting_python_path = { basedpyright = true, pyrefly = true }

local function set_python_path(path)
    local clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
    for _, client in ipairs(clients) do
        if lsps_supporting_python_path[client.name] then
            local settings = vim.tbl_deep_extend('force', client.settings or {}, { python = { pythonPath = path } })
            client.settings = settings
            client.config.settings = settings
            client:notify('workspace/didChangeConfiguration', { settings = settings })
        end
    end
end

autocmd('User', {
    group = my_augroup,
    desc = 'set python path',
    pattern = 'PythonEnvActivate',
    callback = function(event)
        set_python_path(event.data.venv_path .. '/bin/python3')
    end,
})

autocmd('User', {
    group = my_augroup,
    pattern = 'CondaEnvActivate',
    desc = 'set python path',
    callback = function(event)
        set_python_path(event.data.conda_env_path .. '/bin/python3')
    end,
})

autocmd('FileType', {
    pattern = { 'python', 'markdown', 'quarto', 'rmd' },
    group = my_augroup,
    desc = 'Add edit inline keymap',
    callback = function()
        bufmap(0, 'n', "<LocalLeader>'", '', {
            desc = 'Edit inline string (typically inline SQL)or code block in a dedicated temporary buffer',
            callback = require('conf.edit_inline').edit_inline,
        })
    end,
})

return M
