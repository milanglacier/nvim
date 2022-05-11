local M = {}

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.api.nvim_set_keymap

M.my_vscode = augroup('MyVSCode', {})
autocmd({ 'BufNewFile', 'BufFilePre', 'BufRead' }, {
    group = M.my_vscode,
    desc = 'set the filetype of jupyter notebook cell to python',
    pattern = { '*.ipynb*' },
    -- jupyter notebook cell will end with *.ipynb*
    callback = function()
        vim.bo.filetype = 'python'
    end,
})

local function notify(cmd)
    return string.format("<cmd>call VSCodeNotify('%s')<CR>", cmd)
end

local function v_notify(cmd)
    return string.format("<cmd>call VSCodeNotifyVisual('%s', 1)<CR>", cmd)
end

keymap('n', '<Leader>rg', notify 'workbench.action.findInFiles', { silent = true })

keymap('n', '<Leader>xr', notify 'references-view.findReferences', { silent = true })
keymap('n', '<Leader>xd', notify 'workbench.actions.view.problems', { silent = true })
keymap('n', 'gr', notify 'editor.action.goToReferences', { silent = true })
keymap('n', '<Leader>rn', v_notify 'editor.action.rename', { silent = true })
keymap('n', '<Leader>fm', notify 'editor.action.formatDocument', { silent = true })
keymap('n', '<Leader>ca', notify 'editor.action.refactor', { silent = true })

keymap('n', '<Leader>bv', notify 'workbench.action.toggleSidebarVisibility', { silent = true })
keymap('n', '<Leader>av', notify 'workbench.action.toggleAuxiliaryBar', { silent = true })
keymap('n', '<Leader>pv', notify 'workbench.action.togglePanel', { silent = true })

keymap('v', '<Leader>fm', v_notify 'editor.action.formatSelection', { silent = true })
keymap('v', '<Leader>ca', v_notify 'editor.action.refactor', { silent = true })

return M
