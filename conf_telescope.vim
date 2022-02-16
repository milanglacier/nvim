lua <<EOF
require('telescope').load_extension('fzf')

local telescope = require('telescope')
telescope.setup {
    pickers = {
        find_files = {
            find_command = {'rg', '--files', '--iglob', '!.git', '--hidden'},
        }
    }
}




require'nvim-web-devicons'.setup()
EOF
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr> nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

