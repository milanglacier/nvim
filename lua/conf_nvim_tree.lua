-- init.lua

-- following options are the default
-- each of these are documented in `:help nvim-tree.OPTION_NAME`


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
        mappins = {
        { key = "?", action = "toggle_help" },

        }
    }
}

local map = vim.api.nvim_set_keymap
map('n', "<leader>tt", "<cmd>NvimTreeToggle<CR>", {noremap = true, silent = true})
map('n', "<leader>tf", "<cmd>NvimTreeFindFileToggle<CR>", {noremap = true, silent = true})
map('n', "<leader>tr", "<cmd>NvimTreeRefresh<CR>", {noremap = true, silent = true})

-- " vimrc
-- " let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
-- " let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
-- " let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
-- " let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
-- " let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
-- " let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
-- " let g:nvim_tree_icon_padding = ' ' "one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
-- " let g:nvim_tree_symlink_arrow = ' >> ' " defaults to ' ➛ '. used as a separator between symlinks' source and target.
-- " let g:nvim_tree_respect_buf_cwd = 1 "0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
-- " let g:nvim_tree_create_in_closed_folder = 1 "0 by default, When creating files, sets the path of a file when cursor is on a closed folder to the parent folder when 0, and inside the folder when 1.
-- " let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1 } " List of filenames that gets highlighted with NvimTreeSpecialFile
-- " let g:nvim_tree_show_icons = {
-- "     \ 'git': 1,
-- "     \ 'folders': 1,
-- "     \ 'files': 1,
-- "     \ 'folder_arrows': 1,
-- "     \ }
-- " "If 0, do not show the icons for one of 'git' 'folder' and 'files'
-- " "1 by default, notice that if 'files' is 1, it will only display
-- " "if nvim-web-devicons is installed and on your runtimepath.
-- " "if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
-- " "but this will not work when you set indent_markers (because of UI conflict)
-- "
-- " " default will show icon by default if no icon is provided
-- " " default shows no icon by default
-- let g:nvim_tree_icons = {
--     \ 'default': '',
--     \ 'symlink': '',
--     \ 'git': {
--     \   'unstaged': "✗",
--     \   'staged': "✓",
--     \   'unmerged': "",
--     \   'renamed': "➜",
--     \   'untracked': "★",
--     \   'deleted': "",
--     \   'ignored': "◌"
--     \   },
--     \ 'folder': {
--     \   'arrow_open': "",
--     \   'arrow_closed': "",
--     \   'default': "",
--     \   'open': "",
--     \   'empty': "",
--     \   'empty_open': "",
--     \   'symlink': "",
--     \   'symlink_open': "",
--     \   }
--     \ }
--
--
--
-- nnoremap <leader>tt :NvimTreeToggle<CR>
-- " nnoremap <leader>tr :NvimTreeRefresh<CR>
-- nnoremap <leader>tf :NvimTreeFindFileToggle<CR>
-- " nnoremap <leader>tfc :NvimTreeFocus<CR>
-- " NvimTreeOpen, NvimTreeClose, NvimTreeFocus, NvimTreeFindFileToggle, and NvimTreeResize are also available if you need them
--
-- set termguicolors " this variable must be enabled for colors to be applied properly
--
-- " a list of groups can be found at `:help nvim_tree_highlight`
--
--
