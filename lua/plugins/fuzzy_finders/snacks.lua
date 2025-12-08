local M = {}

local opts_desc = function(desc)
    return {
        noremap = true,
        desc = desc,
        silent = true,
    }
end

local function snacks(cmd)
    return string.format('<cmd>lua require("snacks").picker.%s<cr>', cmd)
end

local keymap = vim.api.nvim_set_keymap

--- enable snacks.picker module
Milanglacier.snacks.module.picker = function()
    keymap('n', '<Leader>ff', snacks 'files { hidden = true }', opts_desc 'Find Files')
    keymap('n', '<Leader>fF', snacks 'files { hidden = true, ignored = true }', opts_desc 'Find Files No ignore')
    keymap('n', '<Leader>fg', snacks 'grep { hidden = true }', opts_desc 'Find Live Grep')
    keymap('n', '<Leader>fG', '<cmd>FF grep_string<cr>', opts_desc 'Find Grep')

    keymap('n', '<Leader>fb', snacks 'buffers()', opts_desc 'Find buffers')
    keymap('n', '<Leader>fh', snacks 'help()', opts_desc 'Find helptags')
    keymap('n', '<Leader>fk', snacks 'keymaps()', opts_desc 'Find keymaps')

    keymap('n', '<Leader>fc', snacks 'commands()', opts_desc 'Find commands')
    keymap('n', '<Leader>fC', snacks 'command_history()', opts_desc 'Find commands history')

    keymap('n', '<leader>fs', snacks 'lsp_symbols()', opts_desc 'lsp doc symbol')
    keymap('n', '<leader>fw', snacks 'lsp_workspace_symbols()', opts_desc 'lsp workspace symbol')
    keymap('n', '<leader>fr', snacks 'registers()', opts_desc 'Find registers')
    keymap('n', '<leader>fj', snacks 'jumps()', opts_desc 'Find jumplist')
    keymap('n', '<leader>fo', snacks 'recent()', opts_desc 'Find oldfilels')
    keymap('n', '<leader>fT', snacks 'treesitter()', opts_desc 'Find Treesitter')
    keymap('n', '<leader>ft', snacks 'tags()', opts_desc 'Find Tags')
    keymap('n', '<leader>fm', snacks 'marks()', opts_desc 'Find Marks')
    keymap('n', '<leader>fu', snacks 'undo', opts_desc 'Find Undotree')

    keymap('n', '<leader>fe', snacks 'pickers()', opts_desc 'Find extensions')
    keymap('n', '<leader>gml', snacks 'git_log()', opts_desc 'Git Log')
    keymap('n', '<leader>gmb', snacks 'git_log_file()', opts_desc 'Git Buffer Log')
    keymap('v', '<leader>gmb', snacks 'git_log_line()', opts_desc 'Git Hunk Log')

    Milanglacier.snacks.opts.picker = {
        win = {
            input = {
                keys = {
                    -- Snacks by default enables C-a to select all in insert mode,
                    -- but we only want to use C-a to select all in normal mode.
                    ['<C-/>'] = { 'toggle_help_list', mode = { 'n', 'i' } },
                    ['<C-a>'] = 'select_all',
                    ['<M-a>'] = { 'select_all', mode = { 'n', 'i' } },
                    ['<M-q>'] = { 'qflist', mode = { 'i', 'n' } },
                    -- Disable the default <C-k> mapping in Snacks to preserve
                    -- the standard Bash-like kill-line behavior.
                    ['<C-k>'] = false,
                },
            },
        },
        layout = {
            preset = 'vertical',
            layout = {
                -- HACK: Increase the proportion of the preview window by
                -- modifying the third element from the vertical preset. This
                -- approach is somewhat unorthodox, as it alters a positional
                -- array element rather than extending a key-value pair in a
                -- Lua table. Be aware that this solution may break with future
                -- updates.
                [3] = { win = 'preview', title = '{preview}', height = 0.6, border = 'top' },
                width = 0.85,
                height = 0.6,
            },
        },
    }
end

return M
