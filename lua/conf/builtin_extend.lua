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

keymap('i', '<C-b>', '<Left>', opts)
keymap('i', '<C-p>', '<Up>', opts)
keymap('i', '<C-f>', '<Right>', opts)
keymap('i', '<C-n>', '<Down>', opts)
keymap('i', '<C-a>', '<home>', opts)
keymap('i', '<C-e>', '<end>', opts)
keymap('i', '<C-h>', '<BS>', opts)
keymap('i', '<C-d>', '<Del>', opts)
keymap('i', '<C-k>', '<C-o>D', opts)

-- cannot use { silent = true } here, the reason is unknown.
keymap('c', '<C-b>', '<Left>', { noremap = true })
keymap('c', '<C-p>', '<Up>', { noremap = true })
keymap('c', '<C-f>', '<Right>', { noremap = true })
keymap('c', '<C-n>', '<Down>', { noremap = true })
keymap('c', '<C-a>', '<home>', { noremap = true })
keymap('c', '<C-e>', '<end>', { noremap = true })
keymap('c', '<C-h>', '<BS>', { noremap = true })
keymap('c', '<C-d>', '<Del>', { noremap = true })
keymap('c', '<C-k>', [[<C-\>e(strpart(getcmdline(), 0, getcmdpos() - 1))<CR>]], { noremap = true })
-- do the same as <C-k> in insert mode is a bit complex in cmdline mode.
keymap('c', '<A-b>', '<S-Left>', { noremap = true })
keymap('c', '<A-f>', '<S-Right>', { noremap = true })

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
    keymap('t', 'k', [[<BS><C-\><C-N>]], opts)
    keymap('i', 'k', [[<BS><ESC>]], opts)
    keymap('v', 'k', [[k<ESC>]], opts)
    vim.defer_fn(function()
        pcall(vim.api.nvim_del_keymap, 't', 'k')
        pcall(vim.api.nvim_del_keymap, 'i', 'k')
        pcall(vim.api.nvim_del_keymap, 'v', 'k')
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
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 400 }
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
        filename = vim.fn.shellescape(filename)

        if vim.fn.has 'mac' == 1 then
            vim.cmd['!'] { 'open', filename }
            vim.cmd.redraw()

            vim.defer_fn(function()
                vim.cmd.bdelete { bang = true }
            end, 1000)
        end
    end,
})

function M.open_URI_under_cursor(use_w3m)
    local function open_uri(uri)
        if type(uri) ~= 'nil' then
            uri = string.gsub(uri, '#', '\\#') --double escapes any # signs
            uri = '"' .. uri .. '"'

            if use_w3m then
                vim.cmd.terminal { 'w3m', uri }
                return true
            end

            vim.cmd['!'] { 'open', uri }
            vim.cmd.redraw()
            return true
        else
            return false
        end
    end

    local word_under_cursor = vim.fn.expand '<cWORD>'
    -- any uri with a protocol segment
    local regex_protocol_uri = '%a*:%/%/[%a%d%#%[%]%-%%+:;!$@/?&=_.,~*()]*[^%)]'
    if open_uri(string.match(word_under_cursor, regex_protocol_uri)) then
        return
    end
    -- consider anything that looks like string/string a github link
    local regex_plugin_url = '[%a%d%-%.%_]*%/[%a%d%-%.%_]*'
    if open_uri('https://github.com/' .. string.match(word_under_cursor, regex_plugin_url)) then
        return
    end
end

command('OpenURIUnderCursor', M.open_URI_under_cursor, {})
command('OpenURIUnderCursorWithW3m', function()
    M.open_URI_under_cursor(true)
end, {})

keymap('n', '<Leader>olx', '', {
    callback = M.open_URI_under_cursor,
    noremap = true,
    desc = 'open URI under the cursor with xdg-open',
})

keymap('n', '<Leader>olw', '', {
    callback = function()
        M.open_URI_under_cursor(true)
    end,
    noremap = true,
    desc = 'open URI under the cursor with w3m',
})

command('Wbq', 'w | bd', {})
-- this is useful with integration with `nvr` which allows you to prevent from
-- nested nvim instance when neovim's builtin terminal trys to invoke nvim
-- instance.
--
-- NOTE: when nvim instance is invoked via `nvr`, you can't use
-- standard `:wq` to quit the instance since it is still running. You need to
-- delete the buffer. That is, either using ':bd' (don't save the result), or
-- ':Wbq' (save the result) to finish the editing.

return M
