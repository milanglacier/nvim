local M = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

local git_workspace_diff_setup = function()
    local function is_a_git_dir()
        local is_git = vim.fs.root(vim.fn.getcwd(), '.git')
        return is_git
    end

    local function compute_workspace_diff(cwd)
        vim.system({ 'git', 'diff', '--stat' }, { text = true }, function(obj)
            local stdout = vim.split(obj.stdout, '\n')
            -- if there are diffs, then there will be at least two lines, the
            -- 1:n-2 lines are the changed file name, and the second last line
            -- is the stats, and the last line is an empty string.
            if #stdout < 2 then
                return
            end

            -- get the second last line containing the stats
            local changes_raw = stdout[#stdout - 1]

            local changes_table = vim.split(changes_raw, ',')

            local changes = ''

            for _, i in pairs(changes_table) do
                if i:find 'change' then
                    changes = changes .. ' ' .. i:match '(%d+)'
                elseif i:find 'insertion' then
                    changes = changes .. ' +' .. i:match '(%d+)'
                elseif i:find 'deletion' then
                    changes = changes .. ' -' .. i:match '(%d+)'
                end
            end

            if changes ~= '' then
                changes = ' ' .. changes
            end

            M.git_workspace_diff[cwd] = changes
        end)
    end

    local function init_workspace_diff()
        local cwd = vim.fn.getcwd()

        if M.git_workspace_diff[cwd] == nil and is_a_git_dir() then
            compute_workspace_diff(cwd)
        end
    end

    local function update_workspace_diff()
        local cwd = vim.fn.getcwd()
        if M.git_workspace_diff[cwd] ~= nil then
            compute_workspace_diff(cwd)
        end
    end

    autocmd('BufEnter', {
        group = my_augroup,
        desc = 'Init the git diff',
        callback = function()
            vim.defer_fn(function()
                init_workspace_diff()
                -- defer this function because project root need to be updated.
            end, 100)
        end,
    })
    autocmd('BufWritePost', {
        group = my_augroup,
        desc = 'Update the git diff',
        callback = function()
            vim.defer_fn(function()
                update_workspace_diff()
            end, 100)
        end,
    })
end

M.get_workspace_diff = function()
    local cwd = vim.fn.getcwd()
    -- don't use pattern matching
    if vim.fn.expand('%:p'):find(cwd, nil, true) then
        -- if the absolute path of current file is a sub directory of cwd
        return M.git_workspace_diff[cwd] or ''
    else
        return ''
    end
end

M.winbar_symbol = function()
    if not vim.lsp.buf_is_attached(0) then
        return ''
    end

    local navic = require 'nvim-navic'

    if navic.is_available() then
        return navic.get_location()
    end

    return ''
end

M.git_workspace_diff = {}

M.reopen_qflist_by_trouble = function()
    local windows = vim.api.nvim_list_wins()

    for _, winid in ipairs(windows) do
        local bufid = vim.api.nvim_win_get_buf(winid)
        local buf_filetype = vim.api.nvim_buf_get_option(bufid, 'filetype')
        if buf_filetype == 'qf' then
            vim.api.nvim_win_close(winid, true)
        end
    end
    require('trouble').toggle 'quickfix'
end

M.trouble_workspace_diagnostics = function()
    require('trouble').toggle {
        mode = 'diagnostics',
        filter = function(items)
            return vim.tbl_filter(function(item)
                return item.dirname:find(vim.uv.cwd(), 1, true)
            end, items)
        end,
    }
end

git_workspace_diff_setup()

return M
