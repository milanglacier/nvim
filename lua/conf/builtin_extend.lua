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

M.magic_prefix = ''
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
keymap('i', '<C-k>', '<ESC>d$i', opts)

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

function M.textobj_code_chunk(ai, start_pattern, end_pattern, has_same_start_end_pattern)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local max_row = vim.api.nvim_buf_line_count(0)

    -- nvim_buf_get_lines is 0 indexed, while nvim_win_get_cursor is 1 indexed
    local chunk_start = nil

    for row_idx = row, 1, -1 do
        local line_content = vim.api.nvim_buf_get_lines(0, row_idx - 1, row_idx, false)[1]

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
            local line_content = vim.api.nvim_buf_get_lines(0, row_idx - 1, row_idx, false)[1]

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
                vim.cmd.normal { 'V', bang = true }
            elseif internal_length > 0 then
                vim.cmd.normal { 'V' .. internal_length .. 'j', bang = true }
            end
        end

        if ai == 'a' then
            vim.api.nvim_win_set_cursor(0, { chunk_start, 0 })
            local chunk_length = chunk_end - chunk_start
            vim.cmd.normal { 'V' .. chunk_length .. 'j', bang = true }
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

        if vim.fn.has 'mac' == 1 then
            vim.cmd['!'] { 'open', filename }
            vim.cmd.redraw()

            vim.defer_fn(function()
                vim.cmd.bdelete { bang = true }
            end, 1000)
        end
    end,
})

---for python, type `df.columns` to print names of columns
---in REPL, and then type `yi]` to yank the inner part of the list,
---then switch back to the python file buffer and then call this function
---
---for R, type `colnames(df)` to print names of columns
---in REPL, and then type `yap` to yank the whole region
---then switch back to the R file buffer and then call this function
---
---Currently, the names of columns cannot contain special characters and white characters
---due to how the processing is handled
---@param df string | nil @the data frame name for yanked columns
---@param use_customized_parser boolean | nil @whether use customized parser
---@param destination string | nil @which tags file will be used to store columns information
function M.create_tags_for_yanked_columns(df, use_customized_parser, destination)
    local ft = vim.bo.filetype
    if not (ft == 'r' or ft == 'python' or ft == 'rmd') then
        return
    end

    if df == nil then
        df = 'df'
    end

    if destination == nil then
        destination = '.tags_columns'
    end

    local bufid = vim.api.nvim_get_current_buf()

    vim.cmd '!mkdir -p .auxtags'
    local newfile = '.auxtags/.tags_' .. df

    vim.cmd.edit(newfile) -- open a file whose name is .tags_$current_file
    local newtag_bufid = vim.api.nvim_get_current_buf()

    vim.cmd [[normal! ggdG]] -- clear the buffer
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

    if use_customized_parser then
        M.generate_code_for_tagging_with_customized_parser(ft, df)
    else
        M.generate_code_for_tagging_without_customized_parser(ft, df)
    end

    vim.cmd.sort 'u' -- remove duplicated entry
    vim.cmd.write() -- save current buffer

    local newfile_shell_escaped = vim.fn.shellescape(newfile)
    -- replace . by \. such that it is recognizable by vim regex
    -- replace / by \/
    local newfile_vim_regexed = newfile_shell_escaped:gsub('%.', [[\.]])
    newfile_vim_regexed = newfile_vim_regexed:gsub('/', [[\/]])
    newfile_vim_regexed = newfile_vim_regexed:sub(2, -2) -- remove the first and last chars, i.e. ' and '

    vim.cmd.edit(destination) -- open the file where ctags stores the tags
    local tag_bufid = vim.api.nvim_get_current_buf()

    vim.cmd.global { '/' .. newfile_vim_regexed .. '/d' }
    -- remove existed entries for the current newtag file
    vim.cmd.write()

    if ft == 'rmd' then
        ft = 'r'
    end

    vim.cmd['!'] {
        'ctags',
        '-a',
        '-f',
        destination,
        [[--fields='*']],
        '--language-force=' .. ft,
        newfile_shell_escaped,
    }
    -- let ctags tag current newtag file

    vim.api.nvim_win_set_buf(0, bufid)
    vim.cmd.bdelete { count = newtag_bufid, bang = true } -- delete the buffer created for tagging
    vim.cmd.bdelete { count = tag_bufid, bang = true } -- delete the ctags tag buffer
    vim.cmd.nohlsearch() -- remove matched pattern's highlight
end

function M.generate_code_for_tagging_without_customized_parser(ft, df)
    if ft == 'python' then
        vim.cmd [[%s/'//ge]] -- remove '
        vim.cmd.global { [[/^\w\+$/normal!]], [[A="]] .. df .. [["]] } -- show which dataframe this column belongs to
        -- use " instead of ', for incremental tagging, since ' will be removed.
    else
        vim.cmd [[%s/"//ge]]
        vim.cmd.global { [[/^[[:alnum:]_.]\+$/normal!]], [[A=']] .. df .. [[']] }
        -- r use " to quote strings, in contrary to python
    end
end

function M.generate_code_for_tagging_with_customized_parser(ft, df)
    if df == nil then
        df = 'df'
    end

    if ft == 'python' then
        vim.cmd [[g/^'.\+'$/normal! A]="nameattr"]]
        vim.cmd.global { [[/^'.\+"$/normal!]], 'I' .. df .. '[' }
    else
        vim.cmd [=[g/^".\+"$/normal! A]]<-'nameattr']=]
        vim.cmd.global { [[/^".\+'$/normal!]], 'I' .. df .. '[[' }
    end
end

command('TagYankedColumns', function(options)
    local df = options.args
    M.create_tags_for_yanked_columns(df, true)
end, {
    nargs = '?',
})

command('TagYankedColumnsVanilla', function(options)
    local df = options.args
    M.create_tags_for_yanked_columns(df, false)
end, {
    nargs = '?',
})

autocmd('FileType', {
    group = M.my_augroup,
    pattern = { 'r', 'rmd' },
    desc = 'set r, rmd keyword pattern to include .',
    callback = function()
        vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
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

command('CondaEnv', function(options)
    vim.env.PATH = options.args .. ':' .. vim.env.PATH
end, {
    nargs = 1,
    complete = function(_, _, _)
        local conda_base = vim.env.CONDA_PREFIX
        local conda_env_dir = conda_base .. '/envs'
        local conda_envs = vim.fn.glob(conda_env_dir .. '/*')

        conda_envs = vim.split(conda_envs, '\n')
        table.insert(conda_envs, conda_base)

        conda_envs = vim.tbl_map(function(x)
            return x .. '/bin'
        end, conda_envs)
        return conda_envs
    end,
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
