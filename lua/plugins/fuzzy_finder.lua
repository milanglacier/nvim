local command = vim.api.nvim_create_user_command

local M = {
    {
        import = 'plugins.fuzzy_finders.telescope',
        cond = Milanglacier.fuzzy_finder == 'telescope',
    },
    {
        import = 'plugins.fuzzy_finders.fzf',
        cond = Milanglacier.fuzzy_finder == 'fzf',
    },
}

local fzf = {}
fzf.projects = function()
    local contents = require('project_nvim').get_recent_projects()
    local reverse = {}
    for i = #contents, 1, -1 do
        reverse[#reverse + 1] = contents[i]
    end
    ---@diagnostic disable-next-line: redefined-local
    local fzf = require 'fzf-lua'

    fzf.fzf_exec(reverse, {
        actions = {
            ['default'] = function(e)
                fzf.files { cwd = e[1] }
            end,
        },
    })
end
fzf.oldfiles = 'FzfLua oldfiles'
fzf.find_files = 'FzfLua files'

local telescope = {}
telescope.projects = 'Telescope projects'
telescope.oldfiles = 'Telescope oldfiles'
telescope.find_files = 'Telescope find_files'

M.actions = Milanglacier.fuzzy_finder == 'telescope' and telescope or fzf

command('FF', function(args)
    local fn = M.actions[args.args]
    if type(fn) == 'function' then
        fn()
    else
        vim.cmd(fn)
    end
end, {
    nargs = 1,
    complete = function()
        return vim.tbl_keys(M.actions)
    end,
})

return M
