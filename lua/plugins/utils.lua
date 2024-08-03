local keymap = vim.api.nvim_set_keymap

return {
    { 'folke/lazy.nvim' },
    { 'nvim-lua/plenary.nvim' },
    {
        'ahmedkhalf/project.nvim',
        init = function()
            keymap('n', '<Leader>fp', '<cmd>Telescope projects<CR>', { noremap = true })
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
    {
        'kyazdani42/nvim-tree.lua',
        cmd = { 'NvimTreeToggle', 'NvimTreeFindFileToggle', 'NvimTreeRefresh' },
        init = function()
            keymap('n', '<leader>et', '<cmd>NvimTreeToggle<CR>', { noremap = true, silent = true })
            keymap('n', '<leader>ef', '<cmd>NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
            keymap('n', '<leader>er', '<cmd>NvimTreeRefresh<CR>', { noremap = true, silent = true })
        end,
        config = function()
            -- this function is generated from `NvimTreeGenerateOnAttach`
            local function on_attach(bufnr)
                local api = require 'nvim-tree.api'
                api.config.mappings.default_on_attach(bufnr)
            end

            require('nvim-tree').setup {
                on_attach = on_attach,
                -- this makes nvim-tree opens in project root when switching between projects,
                -- see project.nvim's README
                respect_buf_cwd = true,
                update_cwd = true,
                update_focused_file = {
                    enable = true,
                    update_cwd = true,
                },
                git = {
                    ignore = false,
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
