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

local function set_python_path(path)
    local clients = vim.lsp.get_clients {
        bufnr = vim.api.nvim_get_current_buf(),
        name = 'basedpyright',
    }
    for _, client in ipairs(clients) do
        if client.settings then
            ---@diagnostic disable-next-line:param-type-mismatch
            client.settings.python = vim.tbl_deep_extend('force', client.settings.python or {}, { pythonPath = path })
        else
            client.config.settings =
                vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
        end
        client:notify('workspace/didChangeConfiguration', {})
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
    pattern = 'python',
    group = my_augroup,
    desc = 'Add edit src keymap to python',
    callback = function()
        bufmap(0, 'n', "<LocalLeader>'", '', {
            desc = 'edit src under cursor in a dedicated buffer',
            callback = require('conf.edit_inline').edit_inline_string,
        })
    end,
})

autocmd('FileType', {
    pattern = { 'markdown', 'quarto', 'rmd' },
    group = my_augroup,
    desc = 'Add edit src keymap to markdown',
    callback = function()
        bufmap(0, 'n', "<LocalLeader>'", '', {
            desc = 'edit code block under cursor in a dedicated buffer',
            callback = require('conf.edit_inline').edit_markdown_code_block,
        })
    end,
})

return M
