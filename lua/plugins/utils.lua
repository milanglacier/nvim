local keymap = vim.api.nvim_set_keymap

return {
    { 'folke/lazy.nvim' },
    { 'nvim-lua/plenary.nvim' },
    {
        'ahmedkhalf/project.nvim',
        init = function()
            keymap('n', '<Leader>fp', '<cmd>FF projects<CR>', { noremap = true })
        end,
        config = function()
            require('project_nvim').setup {
                detection_methods = { 'pattern' },
                patterns = { '.git', '.svn', 'Makefile', 'package.json', 'NAMESPACE', 'setup.py' },
                show_hidden = true,
            }
        end,
        lazy = false,
    },
    { 'MunifTanjim/nui.nvim' },
    {
        'nvim-neo-tree/neo-tree.nvim',
        lazy = vim.fn.argc(-1) == 0, -- load on start when opening a directory from the cmdline
        cmd = { 'Neotree' },
        init = function()
            keymap('n', '<leader>ef', '<cmd>Neotree toggle filesystem reveal<cr>', { desc = 'Explorer File' })
            keymap('n', '<leader>eg', '<cmd>Neotree toggle git_status reveal<cr>', { desc = 'Explorer Git' })
        end,
        config = function()
            require('neo-tree').setup {
                open_files_do_not_replace_types = { 'terminal', 'Trouble', 'trouble', 'qf', 'Outline' },
                filesystem = {
                    -- don't let neotree change the cwd when neotree switch to
                    -- another directory.
                    bind_to_cwd = false,
                    use_libuv_file_watcher = true,
                    follow_current_file = { enabled = true },
                    hijack_netrw_behavior = 'open_current',
                    filtered_items = {
                        hide_dotfiles = false,
                        hide_gitignored = false,
                        never_show = {
                            '.DS_Store',
                        },
                    },
                },
                window = {
                    mappings = {
                        ['l'] = 'open',
                        ['h'] = 'close_node',
                        ['<space>'] = 'none',
                    },
                },
            }
        end,
    },
    {
        'sindrets/winshift.nvim',
        cmd = 'WinShift',
        init = function()
            keymap('n', '<Leader>wm', '<cmd>WinShift<CR>', { noremap = true, silent = true })
        end,
        config = function()
            require('winshift').setup {}
        end,
    },
}
