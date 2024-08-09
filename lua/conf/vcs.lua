local M = {}
local keymap = vim.api.nvim_set_keymap

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
            vim.cmd 'tabclose'
        end,
    })
    vim.cmd 'startinsert'
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
