local M = {}

local augroup = vim.api.nvim_create_augroup
local keymap = vim.api.nvim_set_keymap
local autocmd = vim.api.nvim_create_autocmd
local bufmap = vim.api.nvim_buf_set_keymap

local opts = { silent = true }
local function opts_desc(desc, callback)
    return {
        silent = true,
        desc = desc,
        callback = callback,
    }
end

--copied from https://github.com/vscode-neovim/vscode-neovim/blob/master/vim/vscode-window-commands.vim
local function split(direction)
    return function()
        if direction == 'v' then
            vim.cmd.call [[VSCodeCall('workbench.action.splitEditorDown')]]
        else
            vim.cmd.call [[VSCodeCall('workbench.action.splitEditorRight')]]
        end
    end
end

local function manage_height_or_width(position, direction)
    local action = {
        w = {
            ['+'] = [[VSCodeNotify('workbench.action.increaseViewWidth')]],
            ['-'] = [[VSCodeNotify('workbench.action.decreaseViewWidth')]],
        },
        h = {
            ['+'] = [[VSCodeNotify('workbench.action.increaseViewHeight')]],
            ['-'] = [[VSCodeNotify('workbench.action.decreaseViewHeight')]],
        },
    }
    return function()
        local count
        if vim.v.count > 1 then
            count = vim.v.count
        else
            count = 1
        end
        for _ = 1, count do
            vim.cmd.call(action[position][direction])
        end
    end
end

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
keymap('n', '<C-w>]', notify 'editor.action.revealDefinitionAside', opts) -- language code actions
keymap('n', '<Leader>w]', notify 'editor.action.revealDefinitionAside', opts) -- language code actions

keymap('n', '<Leader>fR', notify 'workbench.action.findInFiles', opts) -- use ripgrep to search files
keymap('n', '<Leader>ts', notify 'workbench.action.toggleSidebarVisibility', opts)
keymap('n', '<Leader>th', notify 'workbench.action.toggleAuxiliaryBar', opts) -- toggle docview (help page)
keymap('n', '<Leader>tp', notify 'workbench.action.togglePanel', opts)
keymap('n', '<Leader>fc', notify 'workbench.action.showCommands', opts) -- find commands
keymap('n', '<Leader>ff', notify 'workbench.action.quickOpen', opts) -- find files
keymap('n', '<Leader>tw', notify 'workbench.action.terminal.toggleTerminal', opts) -- terminal window

keymap('n', '<Leader>mp', notify 'markdown.showPreviewToSide', opts) -- markdown preview

--copied from https://github.com/vscode-neovim/vscode-neovim/blob/master/vim/vscode-window-commands.vim
keymap('n', '<Leader>ww', notify 'workbench.action.focusNextGroup', opts)
keymap('n', '<Leader>wp', notify 'workbench.action.focusPreviousGroup', opts)
keymap('n', '<Leader>wq', notify 'workbench.action.closeActiveEditor', opts)
keymap('n', '<Leader>wc', notify 'workbench.action.closeActiveEditor', opts)
keymap('n', '<Leader>wo', notify 'workbench.action.joinAllGroups', opts)
keymap('n', '<Leader>w=', notify 'workbench.action.evenEditorWidths', opts)
keymap('n', '<Leader>wh', notify 'workbench.action.focusLeftGroup', opts)
keymap('n', '<Leader>wj', notify 'workbench.action.focusBelowGroup', opts)
keymap('n', '<Leader>wk', notify 'workbench.action.focusAboveGroup', opts)
keymap('n', '<Leader>wl', notify 'workbench.action.focusRightGroup', opts)

-- in vim, a tab contains multiple windows
-- in vscode a window contains multiple tabs
-- the following rearrange the window layout (and together with all the tabs that belong to the window)
keymap('n', '<Leader>wH', notify 'workbench.action.moveActiveEditorGroupLeft', opts)
keymap('n', '<Leader>wJ', notify 'workbench.action.moveActiveEditorGroupDown', opts)
keymap('n', '<Leader>wK', notify 'workbench.action.moveActiveEditorGroupUp', opts)
keymap('n', '<Leader>wL', notify 'workbench.action.moveActiveEditorGroupRight', opts)

-- the following config move tab to different window
keymap('n', '<Leader>wu', notify 'workbench.action.moveEditorToAboveGroup', opts)
keymap('n', '<Leader>wd', notify 'workbench.action.moveEditorToBelowGroup', opts)
keymap('n', '<Leader>wb', notify 'workbench.action.moveEditorToLeftGroup', opts) --backward
keymap('n', '<Leader>wf', notify 'workbench.action.moveEditorToRightGroup', opts) --forward

keymap('n', '<Leader>ws', '', opts_desc('split', split 'v'))
keymap('n', '<Leader>wv', '', opts_desc('split', split 'h'))
keymap('n', '<Leader>w+', '', opts_desc('inc height', manage_height_or_width('h', '+')))
keymap('n', '<Leader>w-', '', opts_desc('dec height', manage_height_or_width('h', '-')))
keymap('n', '<Leader>w>', '', opts_desc('inc width', manage_height_or_width('w', '+')))
keymap('n', '<Leader>w<', '', opts_desc('dec height', manage_height_or_width('w', '-')))

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
    desc = 'set REPL keymaps for python',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>ss', notify 'jupyter.execSelectionInteractive', opts)
        bufmap(0, 'n', '<LocalLeader>sc', notify 'jupyter.runcurrentcell', opts)
        bufmap(0, 'n', '<LocalLeader>sgg', notify 'jupyter.runallcellsabove.palette', opts)
    end,
})

return M
