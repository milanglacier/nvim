local command = vim.api.nvim_create_user_command
local keymap = vim.api.nvim_set_keymap

local M = {
    {
        import = 'plugins.fuzzy_finders.telescope',
        cond = Milanglacier.fuzzy_finder == 'telescope',
    },
    {
        import = 'plugins.fuzzy_finders.fzf',
        cond = Milanglacier.fuzzy_finder == 'fzf',
    },
    {
        import = 'plugins.fuzzy_finders.snacks',
        cond = Milanglacier.fuzzy_finder == 'snacks',
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
                fzf.files { cwd = e[1], cwd_header = false, winopts = { title = e[1] } }
            end,
        },
        winopts = {
            title = 'Recent Projects',
            title_pos = 'center',
        },
    })
end
fzf.oldfiles = 'FzfLua oldfiles'
fzf.find_files = 'FzfLua files'
fzf.repl_show = function()
    require('yarepl.extensions.fzf').repl_show()
end

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
telescope.repl_show = 'Telescope REPLShow'

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

---- snacks ----

local snacks = {}

local snacks_cmd = function(picker, opts)
    return function()
        require('snacks').picker[picker](opts)
    end
end

-- By default, `snacks.picker.projects` displays only the project name. we
-- want it to show the full path instead.
snacks.projects = snacks_cmd('projects', { format = 'text' })
snacks.find_files = snacks_cmd('files', { hidden = true })
snacks.oldfiles = snacks_cmd 'recent'

snacks.repl_show = function()
    require('yarepl.extensions.snacks').repl_show()
end

-- Emulates FzfLua's `grep` or Telescope's `grep_string` command by performing
-- a fuzzy grep with a predefined search query (non-live).
snacks.grep_string = function()
    vim.ui.input({ prompt = 'Enter the string for search: ' }, function(input)
        if not input then
            return
        end

        require('snacks').picker.grep {
            hidden = true,
            search = function()
                return input
            end,
            live = false,
        }
    end)
end

-- lsp
snacks.lsp_type_definitions = snacks_cmd 'lsp_type_definitions'
snacks.lsp_references = snacks_cmd 'lsp_references'
snacks.lsp_definitions = snacks_cmd 'lsp_definitions'
snacks.lsp_implementations = snacks_cmd 'lsp_implementations'

snacks.lsp_incoming_calls = snacks_cmd 'lsp_incoming_calls'
snacks.lsp_outgoing_calls = snacks_cmd 'lsp_outgoing_calls'

snacks.buf_diagnositcs = snacks_cmd 'diagnostics_buffer'
-- only show diagnostics from the cwd by default
snacks.workspace_diagnositcs = snacks_cmd('diagnostics', { filter = { cwd = true } })

-- DAP
-- NOTE: Snacks does not provide pickers for dap.nvim. Therefore, we implement
-- some minimal pickers to handle basic DAP-related functionality, without
-- attempting to replicate the full capabilities of comprehensive picker
-- plugins such as Telescope or fzf.
snacks.dap_commands = function()
    require('snacks').picker.commands()
    vim.defer_fn(function()
        -- Filter by DAP
        vim.api.nvim_feedkeys('Dap', 'n', false)
    end, 300)
end

snacks.dap_configurations = function()
    require('dap').continue()
end

if Milanglacier.fuzzy_finder == 'telescope' then
    M.actions = telescope
elseif Milanglacier.fuzzy_finder == 'fzf' then
    M.actions = fzf
else
    M.actions = snacks
end

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

keymap('n', '<Leader>fR', '<CMD>FF repl_show<CR>', { desc = 'View running REPLs' })

return M
