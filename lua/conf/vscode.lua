local M = {}

local augroup = vim.api.nvim_create_augroup
local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local bufmap = vim.api.nvim_buf_set_keymap

M.my_vscode = augroup('MyVSCode', {})

vim.filetype.add {
    pattern = {
        ['.*%.ipynb.*'] = 'python',
        -- uses lua pattern matching
        -- rathen than naive matching
    },
}

local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

local function v_notify(cmd)
    return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<CR>", cmd)
end

keymap('n', '<Leader>xr', notify 'references-view.findReferences', { silent = true }) -- language references
keymap('n', '<Leader>xd', notify 'workbench.actions.view.problems', { silent = true }) -- language diagnostics
keymap('n', 'gr', notify 'editor.action.goToReferences', { silent = true })
keymap('n', '<Leader>ln', notify 'editor.action.rename', { silent = true })
keymap('n', '<Leader>lf', notify 'editor.action.formatDocument', { silent = true })
keymap('n', '<Leader>la', notify 'editor.action.refactor', { silent = true }) -- language code actions

keymap('n', '<Leader>fR', notify 'workbench.action.findInFiles', { silent = true }) -- use ripgrep to search files
keymap('n', '<Leader>ts', notify 'workbench.action.toggleSidebarVisibility', { silent = true })
keymap('n', '<Leader>th', notify 'workbench.action.toggleAuxiliaryBar', { silent = true }) -- toggle docview (help page)
keymap('n', '<Leader>tp', notify 'workbench.action.togglePanel', { silent = true })
keymap('n', '<Leader>fc', notify 'workbench.action.showCommands', { silent = true }) -- find commands
keymap('n', '<Leader>ff', notify 'workbench.action.quickOpen', { silent = true }) -- find files
keymap('n', '<Leader>tw', notify 'workbench.action.terminal.toggleTerminal', { silent = true }) -- terminal window

keymap('n', '<Leader>mp', notify 'markdown.showPreviewToSide', { silent = true }) -- markdown preview

keymap('v', '<Leader>fm', v_notify 'editor.action.formatSelection', { silent = true })
keymap('v', '<Leader>la', v_notify 'editor.action.refactor', { silent = true })
keymap('v', '<Leader>fc', v_notify 'workbench.action.showCommands', { silent = true })

autocmd('FileType', {
    group = M.my_vscode,
    pattern = { 'r', 'rmd' },
    desc = 'set REPL keymaps for r, rmd',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>ss', notify 'r.runSelection', { silent = true })
        bufmap(0, 'n', '<LocalLeader>sc', notify 'r.runCurrentChunk', { silent = true })
        bufmap(0, 'n', '<LocalLeader>sgg', notify 'r.runAboveChunks', { silent = true })
    end,
})

autocmd('FileType', {
    group = M.my_vscode,
    pattern = { 'python' },
    desc = 'set REPL keymaps for pythono',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>ss', notify 'jupyter.execSelectionInteractive', { silent = true })
        bufmap(0, 'n', '<LocalLeader>sc', notify 'jupyter.runcurrentcell', { silent = true })
        bufmap(0, 'n', '<LocalLeader>sgg', notify 'jupyter.runallcellsabove.palette', { silent = true })
    end,
})

return M
