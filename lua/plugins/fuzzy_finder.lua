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

---- Fzf ----

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

-- dap
fzf.dap_commands = 'FzfLua dap_commands'
fzf.dap_configurations = 'FzfLua dap_configurations'
fzf.dap_breakpoints = 'FzfLua dap_breakpoints'
fzf.dap_variables = 'FzfLua dap_variables'
fzf.dap_frames = 'FzfLua dap_frames'

--lsp
fzf.lsp_type_definitions = 'FzfLua lsp_typedefs'
fzf.lsp_references = 'FzfLua lsp_references'
fzf.lsp_definitions = 'FzfLua lsp_definitions'
fzf.lsp_implementations = 'FzfLua lsp_implementations'

fzf.lsp_incoming_calls = 'FzfLua lsp_incoming_calls'
fzf.lsp_outgoing_calls = 'FzfLua lsp_outgoing_calls'

fzf.buf_diagnositcs = 'FzfLua diagnostics_document'
fzf.workspace_diagnositcs = function()
    require('fzf-lua').diagnostics_workspace {
        cwd_only = true,
    }
end

---- Telescope ____

local telescope = {}
telescope.projects = 'Telescope projects'
telescope.oldfiles = 'Telescope oldfiles'
telescope.find_files = 'Telescope find_files'

-- dap
telescope.dap_commands = function()
    require('telescope').extensions.dap.commands {}
end

telescope.dap_configurations = function()
    require('telescope').extensions.dap.configurations {}
end

telescope.dap_breakpoints = function()
    require('telescope').extensions.dap.list_breakpoints {}
end

telescope.dap_variables = function()
    require('telescope').extensions.dap.variables {}
end

telescope.dap_frames = function()
    require('telescope').extensions.dap.frames {}
end

-- lsp
telescope.lsp_type_definitions = 'Telescope lsp_type_definitions jump_type=tab'
telescope.lsp_references = 'Telescope lsp_references jump_type=tab'
telescope.lsp_definitions = 'Telescope lsp_definitions jump_type=tab'
telescope.lsp_implementations = 'Telescope lsp_implementations jump_type=tab'
telescope.lsp_incoming_calls = 'Telescope lsp_incoming_calls jump_type=tab'
telescope.lsp_outgoing_calls = 'Telescope lsp_outgoing_calls jump_type=tab'

telescope.buf_diagnositcs = 'Telescope diagnostics bufnr=0'
telescope.workspace_diagnositcs = 'Telescope diagnostics root_dir=true'

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
