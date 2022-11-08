local M = {}

local augroup = vim.api.nvim_create_augroup
local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local bufmap = vim.api.nvim_buf_set_keymap

local opts = { silent = true }

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

keymap('n', '<Leader>xr', notify 'references-view.findReferences', opts) -- language references
keymap('n', '<Leader>xd', notify 'workbench.actions.view.problems', opts) -- language diagnostics
keymap('n', 'gr', notify 'editor.action.goToReferences', opts)
keymap('n', '<Leader>ln', notify 'editor.action.rename', opts)
keymap('n', '<Leader>lf', notify 'editor.action.formatDocument', opts)
keymap('n', '<Leader>la', notify 'editor.action.refactor', opts) -- language code actions

keymap('n', '<Leader>fR', notify 'workbench.action.findInFiles', opts) -- use ripgrep to search files
keymap('n', '<Leader>ts', notify 'workbench.action.toggleSidebarVisibility', opts)
keymap('n', '<Leader>th', notify 'workbench.action.toggleAuxiliaryBar', opts) -- toggle docview (help page)
keymap('n', '<Leader>tp', notify 'workbench.action.togglePanel', opts)
keymap('n', '<Leader>fc', notify 'workbench.action.showCommands', opts) -- find commands
keymap('n', '<Leader>ff', notify 'workbench.action.quickOpen', opts) -- find files
keymap('n', '<Leader>tw', notify 'workbench.action.terminal.toggleTerminal', opts) -- terminal window

keymap('n', '<Leader>mp', notify 'markdown.showPreviewToSide', opts) -- markdown preview

keymap('v', '<Leader>lf', v_notify 'editor.action.formatSelection', opts)
keymap('v', '<Leader>la', v_notify 'editor.action.refactor', opts)
keymap('v', '<Leader>fc', v_notify 'workbench.action.showCommands', opts)

autocmd('FileType', {
    group = M.my_vscode,
    pattern = { 'r', 'rmd' },
    desc = 'set REPL keymaps for r, rmd',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>ss', notify 'r.runSelection', opts)
        bufmap(0, 'n', '<LocalLeader>sc', notify 'r.runCurrentChunk', opts)
        bufmap(0, 'n', '<LocalLeader>sgg', notify 'r.runAboveChunks', opts)
    end,
})

autocmd('FileType', {
    group = M.my_vscode,
    pattern = { 'python' },
    desc = 'set REPL keymaps for pythono',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>ss', notify 'jupyter.execSelectionInteractive', opts)
        bufmap(0, 'n', '<LocalLeader>sc', notify 'jupyter.runcurrentcell', opts)
        bufmap(0, 'n', '<LocalLeader>sgg', notify 'jupyter.runallcellsabove.palette', opts)
    end,
})

return M
