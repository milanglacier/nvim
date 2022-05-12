local M = {}

local augroup = vim.api.nvim_create_augroup
local keymap = vim.api.nvim_set_keymap

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
keymap('n', '<Leader>rn', notify 'editor.action.rename', { silent = true })
keymap('n', '<Leader>fm', notify 'editor.action.formatDocument', { silent = true })
keymap('n', '<Leader>ca', notify 'editor.action.refactor', { silent = true }) -- language code actions

keymap('n', '<Leader>rg', notify 'workbench.action.findInFiles', { silent = true }) -- use ripgrep to search files
keymap('n', '<Leader>ts', notify 'workbench.action.toggleSidebarVisibility', { silent = true })
keymap('n', '<Leader>th', notify 'workbench.action.toggleAuxiliaryBar', { silent = true }) -- toggle docview (help page)
keymap('n', '<Leader>tp', notify 'workbench.action.togglePanel', { silent = true })
keymap('n', '<Leader>fc', notify 'workbench.action.showCommands', { silent = true }) -- find commands
keymap('n', '<Leader>ff', notify 'workbench.action.quickOpen', { silent = true }) -- find files
keymap('n', '<Leader>tw', notify 'workbench.action.terminal.toggleTerminal', { silent = true }) -- terminal window

keymap('v', '<Leader>fm', v_notify 'editor.action.formatSelection', { silent = true })
keymap('v', '<Leader>ca', v_notify 'editor.action.refactor', { silent = true })
keymap('v', '<Leader>fc', v_notify 'workbench.action.showCommands', { silent = true })

return M
