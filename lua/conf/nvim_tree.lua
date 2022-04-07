vim.g.nvim_tree_icons = {
    default= '',
    symlink= '',
    git= {
        unstaged= "✗",
        staged= "✓",
        unmerged= "",
        renamed= "➜",
        untracked= "★",
        deleted= "",
        ignored= "◌"
    },
    folder= {
        arrow_open= "",
        arrow_closed= "",
        default= "",
        open= "",
        empty= "",
        empty_open= "",
        symlink= "",
        symlink_open= "",
    }
}

require'nvim-tree'.setup{
    view = {
        mappings = {
            list = { {key = "?", action = "toggle_help" } },

        }
    }
}

local map = vim.api.nvim_set_keymap
map('n', "<leader>tt", "<cmd>NvimTreeToggle<CR>", {noremap = true, silent = true})
map('n', "<leader>tf", "<cmd>NvimTreeFindFileToggle<CR>", {noremap = true, silent = true})
map('n', "<leader>tr", "<cmd>NvimTreeRefresh<CR>", {noremap = true, silent = true})
