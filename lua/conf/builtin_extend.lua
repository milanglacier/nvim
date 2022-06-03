local M = {}

local keymap = vim.api.nvim_set_keymap

keymap('i', 'jk', '<ESC>', { noremap = true })
keymap('t', 'jk', [[<C-\><C-n>]], { noremap = true })

keymap('', [[\]], [[<localleader>]], {})

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

keymap('n', '<Leader>cd', [[:cd %:h<cr>]], { noremap = true })
keymap('n', '<Leader>cu', [[:cd ..<cr>]], { noremap = true })

keymap('n', '<C-g>', '<ESC>', { noremap = true })
-- <C-g> by default echos the current file name, which is useless

keymap('n', ']b', [[:bnext<cr>]], { noremap = true })
keymap('n', '[b', [[:bprevious<cr>]], { noremap = true })
keymap('n', ']q', [[:cnext<cr>]], { noremap = true })
keymap('n', '[q', [[:cprevious<cr>]], { noremap = true })
keymap('n', ']t', [[:tnext<cr>]], { noremap = true })
keymap('n', '[t', [[:tprevious<cr>]], { noremap = true })
keymap('n', '<Leader>tl', [[:ltag <C-R><C-W> | lopen<cr>]], { noremap = true })
-- open loclist to show the definition matches at current word
-- <C-R> insert text in the register to the command line
-- <C-W> alias for the word under cursor

keymap('n', '<Leader>to', [[:tabonly<cr>]], { noremap = true })
keymap('n', '<Leader>tn', [[:tabnew<cr>]], { noremap = true })
keymap('n', '<Leader>tc', [[:tabclose<cr>]], { noremap = true })

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

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

    vim.cmd 'redraw'
    vim.cmd 'sleep 1000m'

    vim.o.cursorline = false
    vim.o.cursorcolumn = false
end

keymap('n', '<Leader>pc', '<cmd>lua require("conf.builtin_extend").ping_cursor()<CR>', { noremap = true })

function M.textobj_code_chunk(ai, start_pattern, end_pattern, has_same_start_end_pattern)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local max_row = vim.api.nvim_buf_line_count(0)

    -- nvim_buf_get_lines is 0 indexed, while nvim_win_get_cursor is 1 indexed
    local chunk_start = nil

    for row_idx = row, 1, -1 do
        local line_content = vim.api.nvim_buf_get_lines(0, row_idx - 1, row_idx, {})[1]

        -- upward searching if find the end_pattern first which means
        -- the cursor pos is not in a chunk, then early return
        -- this method only works when start and end pattern are not same
        if not has_same_start_end_pattern and line_content:match(end_pattern) then
            return
        end

        if line_content:match(start_pattern) then
            chunk_start = row_idx
            break
        end
    end

    -- if find chunk_start then find chunk_end
    local chunk_end = nil

    if chunk_start then
        if chunk_start == max_row then
            return
        end

        for row_idx = chunk_start + 1, max_row, 1 do
            local line_content = vim.api.nvim_buf_get_lines(0, row_idx - 1, row_idx, {})[1]

            if line_content:match(end_pattern) then
                chunk_end = row_idx
                break
            end
        end
    end

    if chunk_start and chunk_end then
        if ai == 'i' then
            vim.api.nvim_win_set_cursor(0, { chunk_start + 1, 0 })
            local internal_length = chunk_end - chunk_start - 2
            if internal_length == 0 then
                vim.cmd [[normal! V]]
            elseif internal_length > 0 then
                vim.cmd([[normal! V]] .. internal_length .. 'j')
            end
        end

        if ai == 'a' then
            vim.api.nvim_win_set_cursor(0, { chunk_start, 0 })
            local chunk_length = chunk_end - chunk_start
            vim.cmd([[normal! V]] .. chunk_length .. 'j')
        end
    end
end

autocmd('FileType', {
    pattern = 'rmd',
    group = M.my_augroup,
    desc = 'set rmarkdown code chunk textobj',
    callback = function()
        local bufmap = vim.api.nvim_buf_set_keymap
        bufmap(0, 'o', 'ac', '', {
            silent = true,
            desc = 'rmd code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '```{.+}', '^```$')
            end,
        })
        bufmap(0, 'o', 'ic', '', {
            silent = true,
            desc = 'rmd code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '```{.+}', '^```$')
            end,
        })

        local visual_a = [[:<C-U>lua require('conf.builtin_extend').textobj_code_chunk('a', '```{.+}', '^```$')<CR>]]

        bufmap(0, 'x', 'ac', visual_a, {
            silent = true,
            desc = 'rmd code chunk text object a',
        })

        local visual_i = [[:<C-U>lua require('conf.builtin_extend').textobj_code_chunk('i', '```{.+}', '^```$')<CR>]]

        bufmap(0, 'x', 'ic', visual_i, {
            silent = true,
            desc = 'rmd code chunk text object i',
        })
    end,
})

autocmd('FileType', {
    pattern = { 'r', 'python' },
    group = M.my_augroup,
    desc = 'set r, python code chunk textobj',
    callback = function()
        local bufmap = vim.api.nvim_buf_set_keymap
        bufmap(0, 'o', 'a<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '^# ?%%%%.*', '^# ?%%%%$', true)
                -- # %%xxxxx or #%%xxxx
            end,
        })
        bufmap(0, 'o', 'i<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '^# ?%%%%.*', '^# ?%%%%$', true)
            end,
        })

        local visual_a =
            [[:<C-U>lua require('conf.builtin_extend').textobj_code_chunk('a', '^# ?%%%%.*', '^# ?%%%%$', true)<CR>]]

        bufmap(0, 'x', 'a<Leader>c', visual_a, {
            silent = true,
            desc = 'code chunk text object a',
        })

        local visual_i =
            [[:<C-U>lua require('conf.builtin_extend').textobj_code_chunk('i', '^# ?%%%%.*', '^# ?%%%%$', true)<CR>]]

        bufmap(0, 'x', 'i<Leader>c', visual_i, {
            silent = true,
            desc = 'code chunk text object i',
        })
    end,
})

autocmd('BufEnter', {
    pattern = { '*.pdf', '*.png', '*.jpg', '*.jpeg' },
    group = M.my_augroup,
    desc = 'open binary files with system default application',
    callback = function()
        local filename = vim.api.nvim_buf_get_name(0)
        filename = vim.fn.shellescape(filename)

        local open_bin = string.format([[!open %s]], filename)
        vim.cmd(open_bin)
        vim.cmd 'redraw'

        vim.defer_fn(function()
            vim.cmd [[bd!]]
        end, 1000)
    end,
})

function M.create_tags_for_yanked_columns(df)
    local ft = vim.bo.filetype
    if not (ft == 'r' or ft == 'python') then
        return
    end

    local bufid = vim.api.nvim_get_current_buf()

    local filepath_head = vim.fn.expand '%:h'
    local filename_tail = vim.fn.expand '%:t'

    local filename_without_extension = filename_tail:match '(.+)%..+'
    local newfile = filepath_head .. '/.tags_' .. filename_without_extension

    vim.cmd(string.format('e %s', newfile)) -- open a file whose name is xxx_tags.extension
    local newtag_bufid = vim.api.nvim_get_current_buf()

    vim.cmd [[normal! Go]] -- go to the end of the buffer and create a new line
    vim.cmd [[normal! "0p]] -- paste the content just yanked into this buffer

    -- flag ge means: replace every occurrences in every line, and
    -- when there are no matched patterns in the document, do not issue an error
    if ft == 'python' then
        vim.cmd [[%s/,//ge]] -- remove every occurrence of ,
    else
        vim.cmd [[g/^r\$>.\+$/d]] -- remove line starts with r$> which usually is the REPL prompt
        vim.cmd [[%s/\[\d\+\]//ge]] -- remove every occurrence of [xxx], where xxx is a number
    end

    vim.cmd [[%s/\s\+/\r/ge]] -- break multiple spaces into a new line
    vim.cmd [[g/^$/d]] -- remove any blank lines

    if ft == 'python' then
        vim.cmd [[%s/'//ge]] -- remove '
        vim.cmd([[g/^\w\+$/normal! A="]] .. df .. [["]]) -- show which dataframe this column belongs to
        -- use " instead of ', for incremental tagging, since ' will be removed.
    else
        vim.cmd [[%s/"//ge]]
        vim.cmd([[g/^\w\+$/normal! A=']] .. df .. [[']])
        -- r use " to quote strings, in contrary to python
    end

    vim.cmd [[sort u]] -- remove duplicated entry
    vim.cmd [[w]] -- save current buffer

    local newfile_shell_escaped = vim.fn.shellescape(newfile)
    -- replace . by \. such that it is recognizable by vim regex
    -- replace / by \/
    local newfile_vim_regexed = newfile_shell_escaped:gsub('%.', [[\.]])
    newfile_vim_regexed = newfile_vim_regexed:gsub('/', [[\/]])
    newfile_vim_regexed = newfile_vim_regexed:sub(2, -2) -- remove the first and last chars, i.e. ' and '

    vim.cmd [[e .tags_columns]] -- open the file where ctags stores the tags
    local tag_bufid = vim.api.nvim_get_current_buf()

    vim.cmd([[g/^\w\+\s\+]] .. newfile_vim_regexed .. [[\s.\+/d]]) -- remove existed entries for the current newtag file
    vim.cmd [[w]]

    vim.cmd([[!ctags -a -f .tags_columns --language-force=]] .. ft .. ' ' .. newfile_shell_escaped) -- let ctags tag current newtag file

    vim.api.nvim_win_set_buf(0, bufid)
    vim.cmd([[bd!]] .. newtag_bufid) -- delete the buffer created for tagging
    vim.cmd([[bd!]] .. tag_bufid) -- delete the ctags tag buffer
    vim.cmd [[noh]] -- remove matched pattern's highlight
end

local command = vim.api.nvim_create_user_command

command('TagYankedColumns', function(options)
    local df = options.args
    M.create_tags_for_yanked_columns(df)
end, {
    nargs = '?',
})

autocmd('FileType', {
    group = M.my_augroup,
    pattern = {'r', 'rmd'},
    desc = "set r, rmd keyword pattern to include .",
    callback = function ()
        vim.bo.iskeyword = vim.bo.iskeyword .. ",."
    end
})

return M
