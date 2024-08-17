local M = {}
local keymap = vim.api.nvim_set_keymap
local bufmap = vim.api.nvim_buf_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

-- referenced from https://github.com/echasnovski/nvim
M.open_lazygit = function()
    if vim.fn.executable 'lazygit' == 0 then
        vim.notify 'Lazygit is not installed'
        return
    end

    vim.cmd 'tabedit'
    vim.cmd 'setlocal nonumber signcolumn=no'

    vim.fn.termopen('lazygit', {
        on_exit = function()
            vim.cmd 'silent! :checktime'
            -- Check if any buffers were changed outside of Vim.
            vim.cmd 'silent! :bw'
        end,
    })
    vim.cmd 'startinsert'
    vim.b[0].jk_esc_undo_sequence = 'k\x1c\x0E' -- k<C-\><C-N>
end

keymap('n', '<Leader>og', '', {
    callback = M.open_lazygit,
    desc = 'LazyGit',
})

M.mini_git_setup = function()
    -- I don't need to use minigit to track status (repo, head, status etc.)
    vim.g.minigit_disable = true
    require('mini.git').setup()
    keymap('n', '<Leader>gc', '', {
        desc = 'Git Commit',
        callback = function()
            vim.cmd 'Git diff --cached --patch-with-stat'
            vim.cmd 'horizontal Git commit'
        end,
    })
    -- commit ammend
    keymap('n', '<Leader>gC', '', {
        desc = 'Git Commit Amend',
        callback = function()
            vim.cmd 'Git diff --cached --patch-with-stat'
            vim.cmd 'horizontal Git commit --amend'
        end,
    })
    keymap('n', '<Leader>gd', '<Cmd>Git diff --patch-with-stat<CR>', { desc = 'Diff' })
    keymap('n', '<Leader>gD', '<Cmd>Git diff --cached --patch-with-stat<CR>', { desc = 'Cached Diff' })
    keymap('n', '<Leader>gl', '<Cmd>Git log --oneline<CR>', { desc = 'Log' })
    keymap('n', '<Leader>gL', '<Cmd>Git log --oneline --follow -- %<CR>', { desc = 'Log buffer' })
    keymap('n', '<Leader>gg', '<Cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'Minigit DWIM' })
    keymap('v', '<Leader>gg', '<Cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'MiniGit DWIM' })

    -- bind show_at_cursor command to CR for git filetype
    autocmd('FileType', {
        group = my_augroup,
        pattern = { 'git', 'diff' },
        callback = function()
            bufmap(0, 'n', '<CR>', '<Cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'MiniGit DWIM' })
        end,
        desc = 'Bind <CR> to Minigit DWIM',
    })
end

local function open_path_at_cursor()
    -- b: backward search
    -- n: do not move cursor
    local lnum_at_file = vim.fn.search('^+++ b/.*$', 'bn')
    if lnum_at_file == 0 then
        return
    end

    -- remove the chracters "b/"
    local file_name = vim.fn.getline(lnum_at_file):match ' b/(.*)$'
    if vim.fn.filereadable(file_name) == 0 then
        return
    end

    -- go to the next line and get the line number of the start of the hunk
    local lnum_at_hunk_start = vim.fn.search([[^@@ -\d\+,\d\+ +\d\+,\d\+ @@]], 'bn')
    if not lnum_at_hunk_start then
        return
    end

    local lnum = vim.fn.getline(lnum_at_hunk_start):match '%+(%d+)'
    if not lnum then
        return
    end

    vim.cmd('tabnew ' .. vim.fn.fnameescape(file_name))
    vim.cmd('normal! ' .. tonumber(lnum) .. 'gg')
end

autocmd('FileType', {
    group = my_augroup,
    pattern = { 'diff' },
    callback = function()
        bufmap(0, 'n', 'g<cr>', '', {
            callback = open_path_at_cursor,
            desc = 'open file at cursor',
        })
    end,
    desc = 'Bind `g<cr>` to open file at cursor',
})

return M
