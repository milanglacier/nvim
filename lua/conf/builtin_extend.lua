local keymap = vim.api.nvim_set_keymap

keymap('i', 'jk', '<ESC>', { noremap = true })
keymap('t', 'jk', [[<C-\><C-n>]], { noremap = true })

vim.g.mapleader = ' '
vim.g.maplocalleader = [[\]]
keymap('', [[<Space><Space>]], [[<LocalLeader>]], {})

keymap('i', '<C-b>', '<Left>', { noremap = true })
keymap('i', '<C-p>', '<Up>', { noremap = true })
keymap('i', '<C-f>', '<Right>', { noremap = true })
keymap('i', '<C-n>', '<Down>', { noremap = true })
keymap('i', '<C-a>', '<home>', { noremap = true })
keymap('i', '<C-e>', '<end>', { noremap = true })
keymap('i', '<C-h>', '<BS>', { noremap = true })
keymap('i', '<C-k>', '<ESC>d$i', { noremap = true })

keymap('t', '<C-b>', '<Left>', { noremap = true })
keymap('t', '<C-p>', '<Up>', { noremap = true })
keymap('t', '<C-f>', '<Right>', { noremap = true })
keymap('t', '<C-n>', '<Down>', { noremap = true })
keymap('t', '<C-a>', '<home>', { noremap = true })
keymap('t', '<C-e>', '<end>', { noremap = true })
keymap('t', '<C-h>', '<BS>', { noremap = true })
keymap('t', '<C-k>', '<ESC>d$i', { noremap = true })

keymap('n', '<Leader>cd', [[:cd %:h<cr>]], { noremap = true })
keymap('n', '<Leader>cu', [[:cd ..<cr>]], { noremap = true })

keymap('n', ']b', [[:bnext<cr>]], { noremap = true })
keymap('n', '[b', [[:bprevious<cr>]], { noremap = true })
keymap('n', ']q', [[:cnext<cr>]], { noremap = true })
keymap('n', '[q', [[:cprevious<cr>]], { noremap = true })

keymap('n', '<Leader>to', [[:tabonly<cr>]], { noremap = true })
keymap('n', '<Leader>tn', [[:tabnew<cr>]], { noremap = true })
keymap('n', '<Leader>tc', [[:tabclose<cr>]], { noremap = true })

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local highlight_yanked_text = augroup('YankedTextHighlight', {})

autocmd('TextYankPost', {
    group = highlight_yanked_text,
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 400 }
    end,
    desc = 'highlight yanked text',
})

local M = {}

function M.ping_cursor()
    vim.o.cursorline = true
    vim.o.cursorcolumn = true

    vim.cmd 'redraw'
    vim.cmd 'sleep 1000m'

    vim.o.cursorline = false
    vim.o.cursorcolumn = false
end

keymap('n', '<Leader>pc', '<cmd>lua require("conf.builtin_extend").ping_cursor()<CR>', { noremap = true })

function M._keymap_add_description(mode, lhs, desc)
    -- allow both leader and Leader to be recognized and translates to the mapped leader key.
    local lhs_, _ = lhs:gsub([[<[Ll]eader>]], vim.g.mapleader)
    lhs_, _ = lhs_:gsub([[<[lL]ocal[lL]eader>]], vim.g.maplocalleader)

    local keymaps = vim.api.nvim_get_keymap(mode)

    local opts_queried

    for _, map in ipairs(keymaps) do
        if map.lhs == lhs_ then
            opts_queried = map
            break
        end
    end

    if opts_queried == nil then
        vim.notify('global keymap ' .. lhs .. ' does not exists!', vim.log.levels.WARN)
        return
    end

    -- remove entries which are not needed by
    -- nvim_set_keymap to avoid error
    local rhs = opts_queried.rhs
    opts_queried.lnum = nil
    opts_queried.sid = nil
    opts_queried.buffer = nil
    opts_queried.mode = nil
    opts_queried.lhs = nil
    opts_queried.rhs = nil

    opts_queried.desc = desc

    keymap(mode, lhs, rhs or '', opts_queried)
end

function M._bufmap_add_description(bufid, mode, lhs, desc)
    -- allow both leader and Leader to be recognized and translates to the mapped leader key.
    local lhs_, _ = lhs:gsub([[<[Ll]eader>]], vim.g.mapleader)
    lhs_, _ = lhs_:gsub([[<[lL]ocal[lL]eader>]], vim.g.maplocalleader)

    local keymaps = vim.api.nvim_buf_get_keymap(bufid, mode)
    local opts_queried

    for _, map in ipairs(keymaps) do
        if map.lhs == lhs_ then
            opts_queried = map
            break
        end
    end

    if opts_queried == nil then
        vim.notify('buffer ' .. bufid .. ' keymap ' .. lhs .. ' does not exists!', vim.log.levels.WARN)
        return
    end

    local bufmap = vim.api.nvim_buf_set_keymap

    local rhs = opts_queried.rhs

    opts_queried.lnum = nil
    opts_queried.sid = nil
    opts_queried.buffer = nil
    opts_queried.mode = nil
    opts_queried.lhs = nil
    opts_queried.rhs = nil

    opts_queried.desc = desc

    bufmap(bufid, mode, lhs, rhs or '', opts_queried)
end

local augroup_add_desc = augroup('AddKeymapDescription', {})

-- example tbl as argument:
-- local tbl = {
--     n = {
--         { '<Leaderff>', 'Telescope find files' },
--         { 'gcc', 'Comment current lines' },
--     },
--     v = { { 'gc', 'Comment selected range' } },
-- }
-- opts: table
-- opts.call_immediately: by default false,
-- set it be true when you want to call this function
-- after nvim is already started.
function M.keymaps_add_descriptions(tbl, opts)
    local function _add_descriptions()
        for mode, keymaps in pairs(tbl) do
            for _, key in pairs(keymaps) do
                M._keymap_add_description(mode, key[1], key[2])
            end
        end
    end

    if opts ~= nil and opts.call_immediately then
        _add_descriptions()
        return
    end

    autocmd('VimEnter', {
        group = augroup_add_desc,
        desc = 'global keymaps add descriptions.',
        callback = function()
            vim.defer_fn(_add_descriptions, 1000)
        end,
    })
end

-- add filetype (buffer local) keymaps' descriptions
-- example tbl
-- local tbl = {
--     ft = { 'lua', 'python' },
--     o = {
--         { 'af', 'treesitter textobj @function.outer' },
--         { 'if', 'treesitter textobj @function.inner' },
--     },
--     n = {
--         { ']f', 'treesitter go the the start of next function' },
--     },
-- }
function M.ft_keymaps_add_descriptions(tbl)
    local ft_pattern = tbl.ft
    tbl.ft = nil

    local function _add_descriptions()
        for mode, keymaps in pairs(tbl) do
            for _, key in pairs(keymaps) do
                M._bufmap_add_description(0, mode, key[1], key[2])
            end
        end
    end

    autocmd('FileType', {
        group = augroup_add_desc,
        pattern = ft_pattern,
        desc = 'filetype ' .. table.concat(ft_pattern, ',') .. ' keymaps add descriptions.',
        callback = function()
            vim.defer_fn(_add_descriptions, 1000)
        end,
    })
end

M.keymaps_add_descriptions {
    n = {
        { '<Leader>ff', 'Telescope find files' },
    },
}
M.ft_keymaps_add_descriptions {
    ft = { 'lua', 'python' },
    o = {
        { 'af', 'treesitter textobj @function.outer' },
        { 'if', 'treesitter textobj @function.inner' },
    },
    n = {
        { ']f', 'treesitter go the the start of next function' },
        { '<Leader>kff', 'treesitter go the the start of next function' },
    },
}

-- local function convert_lhs_to_vim_form(lhs)
--     -- make pattern translation such that lhs code follows the standard
--     -- of what will be represented in nvim_get_keymap()
--     -- NOTE THAT: < standalone (not in the form <xxx>) will be translated to <lt>
--     -- pattern capturing < standalone is a bit complicated, decide to not handle it.
--     -- please pass <lt> if want to use < standlone
--
--     -- translate the keycodes (see h: key-codes) follow the standard form in vim
--     local lhs_, _ = lhs:gsub('<TAB>', '<Tab>')
--     lhs_, _ = lhs:gsub('<[cC][rR]>', '<CR>')
--     lhs_, _ = lhs:gsub('<[Bb][Ss]>', '<BS>')
--     lhs_, _ = lhs:gsub('<ESC>', '<Esc>')
--     lhs_, _ = lhs:gsub('<[Bb]slash>', [[\]])
--     lhs_, _ = lhs:gsub('<BSLASH>', [[\]])
--     lhs_, _ = lhs:gsub('<BAR>', [[|]])
--     lhs_, _ = lhs:gsub('<[Bb]ar>', [[|]])
--     lhs_, _ = lhs:gsub('<[uU][pP]>', [[<Up>]])
--     lhs_, _ = lhs:gsub('<down>', [[<Down>]])
--     lhs_, _ = lhs:gsub('<DOWN>', [[<Down>]])
--     lhs_, _ = lhs:gsub('<left>', [[<Left>]])
--     lhs_, _ = lhs:gsub('<LEFT>', [[<Left>]])
--     lhs_, _ = lhs:gsub('<right>', [[<Right>]])
--     lhs_, _ = lhs:gsub('<RIGHT>', [[<Right>]])
--     lhs_, _ = lhs:gsub('<RIGHT>', [[<Right>]])
--     lhs_, _ = lhs:gsub('<home>', [[<Home>]])
--     lhs_, _ = lhs:gsub('<HOME>', [[<Home>]])
--     lhs_, _ = lhs:gsub('<END>', [[<End>]])
--     lhs_, _ = lhs:gsub('<end>', [[<End>]])
--
--     -- translate <f1> to <F1>, <S-f1> to <S-F1>
--     lhs_, _ = lhs:gsub('(<f)(%d+>)', function(pat1, pat2)
--         return '<F' .. pat2
--     end)
--     lhs_, _ = lhs:gsub('(<S-f)(%d+>)', function(pat1, pat2)
--         return '<S-F' .. pat2
--     end)
--
--     -- translate <A-x> to <M-x>.
--     -- NOTE THAT - is special key, need to use %- to escape.
--     lhs_, _ = lhs:gsub('<A%-', [[<M-]])
--
--     -- translate <C-a> to <C-A>
--     lhs_, _ = lhs:gsub('(<C%-)(%l)(>)', function(pat1, pat2, pat3)
--         return pat1 .. pat2:upper() .. pat3
--     end)
--     return lhs_
-- end
--
-- keymap('n', 'j', '', {
--     callback = function()
--         local vcount1 = vim.api.nvim_get_vvar 'count1'
--         local cursor_pos = vim.api.nvim_win_get_cursor(0)
--         local maxline = vim.api.nvim_buf_line_count(0)
--
--         if vcount1 > 5 then
--             vim.api.nvim_buf_set_mark(0, [[']], cursor_pos[1], cursor_pos[2], {})
--             vim.api.nvim_win_set_cursor(0, { math.min(cursor_pos[1] + vcount1, maxline), cursor_pos[2] })
--         else
--             vim.api.nvim_win_set_cursor(0, { math.min(cursor_pos[1] + vcount1, maxline), cursor_pos[2] })
--         end
--     end,
--     noremap = true,
-- })

-- vim.keymap.set(
--     'n',
--     'j',
--     [[(v:count > 5 ? "m'" . v:count : "") . 'j']],
--     { expr = true, desc = 'if j > 5 then add to jumplist' }
-- )

return M
