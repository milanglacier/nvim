
local telescope = require('telescope')
telescope.setup {
    pickers = {
        find_files = {
            find_command = {'rg', '--files', '--iglob', '!.git', '--hidden'},
        }
    },
    defaults = {
        mappings = {

            i = {

                ["<C-s>"] = "select_horizontal",
                ["<C-b>"] = "preview_scrolling_up",
                ["<C-f>"] = "preview_scrolling_down",
            },

            n = {

                ["t"] = "select_tab",
                ["s"] = "select_horizontal",
                ["v"] = "select_vertical",
                ["<C-b>"] = "preview_scrolling_up",
                ["<C-f>"] = "preview_scrolling_down",
                ["K"] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_worse,
                ["J"] = require('telescope.actions').toggle_selection + require('telescope.actions').move_selection_better,

            }

        },
        layout_strategy = "vertical",
        layout_config = {

            vertical = {

                preview_cutoff = 30
            }

        },
        -- wrap_results = true,
    }
}

require('telescope').load_extension('fzf')
require'nvim-web-devicons'.setup()

local opts = {noremap=true}

vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fk', '<cmd>Telescope keymaps<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fc', '<cmd>Telescope commands<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>ft', '<cmd>Telescope treesitter<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>fr', '<cmd>Telescope registers<cr>', opts)
vim.api.nvim_set_keymap('n', '<leader>F', '<cmd>Telescope<cr>', opts)


