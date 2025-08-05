---@diagnostic disable: param-type-mismatch
local M = {}

local keymap = vim.api.nvim_set_keymap

local opts = { noremap = true, silent = true }
local opts_desc = function(desc)
    return {
        noremap = true,
        silent = true,
        desc = desc,
    }
end

M.magic_prefix = ''
M.emmykeymap = function(mode, lhs, rhs)
    lhs = M.magic_prefix .. lhs
    keymap(mode, lhs, rhs, {
        silent = true,
    })
end

keymap('', [[\]], [[<localleader>]], {})

-- Disable the middle mouse button to prevent accidental clicks.
keymap('', [[<MiddleMouse>]], [[<nop>]], {})

keymap('i', '<C-b>', '<Left>', opts)
keymap('i', '<C-f>', '<Right>', opts)
keymap('i', '<C-a>', '<home>', opts)
keymap('i', '<C-h>', '<BS>', opts)
keymap('i', '<C-d>', '<Del>', opts)
keymap('i', '<C-k>', '<C-o>D', opts)
keymap('i', '<C-e>', [[pumvisible() ? '<C-e>' : '<end>']], {
    desc = 'go to line end or abort completion when pum is visible',
    noremap = true,
    expr = true,
})
keymap('i', '<C-n>', [[pumvisible() ? '<C-n>' : '<down>']], {
    desc = 'Go to next line',
    noremap = true,
    expr = true,
})
keymap('i', '<C-p>', [[pumvisible() ? '<C-p>' : '<up>']], {
    desc = 'Go to previous line',
    noremap = true,
    expr = true,
})

keymap('i', '<A-c><A-c>', '<C-x><C-]>', opts_desc 'Tag completion')
keymap('i', '<A-c><A-f>', '<C-x><C-f>', opts_desc 'File completion')
keymap('i', '<A-c><A-d>', '<C-n>', opts_desc 'Document completion')

keymap('i', '<C-x><C-x>', '<C-x><C-]>', opts_desc 'Tag completion')
keymap('i', '<C-x><C-d>', '<C-n>', opts_desc 'Document completion')

-- cannot use { silent = true } here, the reason is unknown.
keymap('c', '<C-b>', '<Left>', { noremap = true })
keymap('c', '<C-f>', '<Right>', { noremap = true })
keymap('c', '<C-a>', '<home>', { noremap = true })
keymap('c', '<C-e>', '<end>', { noremap = true })
keymap('c', '<C-h>', '<BS>', { noremap = true })
keymap('c', '<C-d>', '<Del>', { noremap = true })
keymap('c', '<C-k>', [[<C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>]], { noremap = true })
-- do the same as <C-k> in insert mode is a bit complex in cmdline mode.
keymap('c', '<A-b>', '<S-Left>', { noremap = true })
keymap('c', '<A-f>', '<S-Right>', { noremap = true })


-- In Vim, `C-b` and `C-f` scroll by a full page, while `C-u` and `C-d` scroll
-- by half a page.  We want to always scroll by a half page.
keymap('n', '<C-f>', '<C-d>', {})
keymap('n', '<C-b>', '<C-u>', {})

keymap('n', '<Leader>mdc', [[:cd %:h|pwd<cr>]], opts)
keymap('n', '<Leader>mdu', [[:cd ..|pwd<cr>]], opts)

keymap('n', '<C-g>', '<ESC>', {})
-- <C-g> by default echos the current file name, which is useless

keymap('n', ']b', [[:bnext<cr>]], opts_desc 'next buffer')
keymap('n', '[b', [[:bprevious<cr>]], opts_desc 'previous buffer')
keymap('n', ']q', [[:cnext<cr>]], opts_desc 'next quicklist entry')
keymap('n', '[q', [[:cprevious<cr>]], opts_desc 'previous quicklist entry')
keymap('n', ']Q', [[:cnewer<cr>]], opts_desc 'newer quicklist')
keymap('n', '[Q', [[:colder<cr>]], opts_desc 'older quicklist')
keymap('n', ']t', [[:tnext<cr>]], opts_desc 'next tag')
keymap('n', '[t', [[:tprevious<cr>]], opts_desc 'previous tag')
keymap('n', '<Leader>mt', [[:ltag <C-R><C-W> | lopen<cr>]], opts_desc 'misc: tag word to loclist')
-- open loclist to show the definition matches at current word
-- <C-R> insert text in the register to the command line
-- <C-W> alias for the word under cursor

keymap('n', '<Leader>bd', [[:bd!<CR>]], opts_desc 'buffer delete current one')
keymap('n', '<Leader>bw', [[:bw!<CR>]], opts_desc 'buffer wipeout current one')
keymap('n', '<Leader>bp', [[:bprevious<CR>]], opts_desc 'buffer next')
keymap('n', '<Leader>bn', [[:bnext<CR>]], opts_desc 'buffer previous')

keymap('n', '<Leader>th', '<cmd>nohlsearch<CR>', opts_desc 'toggle hlsearch')
keymap('n', '<Leader>tw', '<cmd>lua vim.wo.wrap = not vim.wo.wrap<CR>', opts_desc 'toggle wrap')
keymap('n', '<Leader>tn', '<cmd>lua vim.wo.number = not vim.wo.number<CR>', opts_desc 'toggle display linenumber')
keymap(
    'n',
    '<Leader>tc',
    '<cmd>lua vim.wo.conceallevel = vim.wo.conceallevel == 2 and 0 or 2<CR>',
    opts_desc 'toggle conceal'
)
keymap(
    'n',
    '<Leader>tH',
    '<cmd>lua vim.o.cmdheight = vim.o.cmdheight == 0 and 1 or 0<CR>',
    opts_desc 'toggle cmdheight'
)

M.jk_as_esc = function()
    keymap('t', 'k', [[]], {
        noremap = true,
        expr = true,
        callback = function()
            -- some terminal program may want to use different "undo" escape sequence,
            -- for example we want to use `k<C-\><C-N>` as "undo" escape
            -- sequence for lazygit.
            -- In expr mapping, the special key sequence are not interpreted,
            -- we need to input the ascii code of those special key sequence
            -- directly. The default is <BS><C-\><C-N>
            return vim.b[0].jk_esc_undo_sequence or '\x08\x1c\x0E'
        end,
    })
    keymap('i', 'k', [[<BS><ESC>]], opts)
    vim.defer_fn(function()
        pcall(vim.api.nvim_del_keymap, 't', 'k')
        pcall(vim.api.nvim_del_keymap, 'i', 'k')
    end, 100)
    return 'j'
end

local jk_as_esc = {
    noremap = true,
    desc = 'enter jk as esc mode',
    callback = M.jk_as_esc,
    expr = true,
}
keymap('i', 'j', '', jk_as_esc)
keymap('t', 'j', '', jk_as_esc)
keymap('v', 'j', '', jk_as_esc)

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local command = vim.api.nvim_create_user_command

M.my_augroup = augroup('MyAugroup', {})

autocmd('TextYankPost', {
    group = M.my_augroup,
    callback = function()
        vim.hl.on_yank { higroup = 'IncSearch', timeout = 400 }
    end,
    desc = 'highlight yanked text',
})

function M.ping_cursor()
    vim.o.cursorline = true
    vim.o.cursorcolumn = true

    vim.cmd.redraw()
    vim.cmd.sleep { 'm', count = 1000 }

    vim.o.cursorline = false
    vim.o.cursorcolumn = false
end

command('PingCursor', 'lua require("conf.builtin_extend").ping_cursor()', {})

autocmd('BufEnter', {
    pattern = { '*.pdf', '*.png', '*.jpg', '*.jpeg' },
    group = M.my_augroup,
    desc = 'open binary files with system default application',
    callback = function()
        local filename = vim.api.nvim_buf_get_name(0)
        vim.ui.open(filename)

        vim.cmd.redraw()

        vim.defer_fn(function()
            vim.cmd.bdelete { bang = true }
        end, 1000)
    end,
})

command('WQ', 'w | bd', { desc = 'Finishing Editing with nvr.' })
-- this is useful with integration with `nvr` which allows you to prevent from
-- nested nvim instance when neovim's builtin terminal trys to invoke nvim
-- instance.
--
-- NOTE: when nvim instance is invoked via `nvr`, you can't use
-- standard `:wq` to quit the instance since it is still running. You need to
-- delete the buffer. That is, either using ':bd' (don't save the result), or
-- ':WQ' (save the result) to finish the editing.

return M
