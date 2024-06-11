local M = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

local git_workspace_diff_setup = function()
    local function is_a_git_dir()
        local is_git = vim.fn.system 'git rev-parse --is-inside-work-tree' == 'true\n'
        return is_git
    end

    local function compute_workspace_diff(cwd)
        vim.fn.jobstart([[git diff --stat | tail -n 1]], {
            stdout_buffered = true,
            on_stdout = function(_, data, _)
                local changes_raw = data[1]
                changes_raw = string.sub(changes_raw, 1, -2) -- the last character is \n, remove it
                changes_raw = vim.split(changes_raw, ',')

                local changes = ''

                for _, i in pairs(changes_raw) do
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
            end,
        })
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

    local winwidth = vim.api.nvim_win_get_width(0)
    local filename = vim.fn.expand '%:.'

    local winbar = filename

    local rest_length = winwidth - #winbar - 3
    local ts_status = ''

    if rest_length > 5 then
        local size = math.floor(rest_length * 0.8)

        ts_status = require('nvim-treesitter').statusline {
            indicator_size = size,
            separator = '  ',
        } or ''

        if ts_status ~= nil and ts_status ~= '' then
            ts_status = ts_status:gsub('%s+', ' ')
        end
    end

    return ts_status
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
