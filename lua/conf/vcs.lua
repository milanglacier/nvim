local M = {}
local keymap = vim.api.nvim_set_keymap

M.open_lazygit = function()
    -- referenced from https://github.com/echasnovski/nvim
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
    vim.b.minipairs_disable = true
end

keymap('n', '<Leader>og', '', {
    callback = M.open_lazygit,
    desc = 'LazyGit',
})

M.mini_git_setup = function()
    require('mini.git').setup()
    keymap('n', '<Leader>gc', '', {
        desc = 'Git Commit',
        callback = function()
            vim.cmd 'Git diff --cached'
            vim.cmd 'horizontal Git commit'
        end,
    })
    -- commit ammend
    keymap('n', '<Leader>gC', '', {
        desc = 'Git Commit Amend',
        callback = function()
            vim.cmd 'Git diff --cached'
            vim.cmd 'horizontal Git commit --amend'
        end,
    })
    keymap('n', '<Leader>gd', '<Cmd>Git diff<CR>', { desc = 'Diff' })
    keymap('n', '<Leader>gD', '<Cmd>Git diff --cached<CR>', { desc = 'Cached Diff' })
    keymap('n', '<Leader>gl', '<Cmd>Git log --oneline<CR>', { desc = 'Log' })
    keymap('n', '<Leader>gL', '<Cmd>Git log --oneline --follow -- %<CR>', { desc = 'Log buffer' })
    keymap('n', '<Leader>gg', '<Cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'Minigit DWIM' })
    keymap('v', '<Leader>gg', '<Cmd>lua MiniGit.show_at_cursor()<CR>', { desc = 'MiniGit DWIM' })
end

return M
