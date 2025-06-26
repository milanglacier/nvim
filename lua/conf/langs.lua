local M = {}

local api = vim.api
local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufmap = vim.api.nvim_buf_set_keymap

autocmd('FileType', {
    group = my_augroup,
    pattern = { 'r', 'rmd', 'quarto' },
    desc = 'set r, rmd, and quarto keyword pattern to include .',
    callback = function()
        vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
    end,
})

autocmd('FileType', {
    group = my_augroup,
    pattern = 'go',
    desc = 'set buffer opts for go',
    callback = function()
        vim.bo.expandtab = false
        -- go uses tab instead of spaces.
    end,
})

autocmd('FileType', {
    group = my_augroup,
    pattern = 'sql',
    desc = 'set commentstring for sql',
    callback = function()
        vim.bo.commentstring = '-- %s'
    end,
})

local function set_python_path(path)
    local clients = vim.lsp.get_clients {
        bufnr = vim.api.nvim_get_current_buf(),
        name = 'basedpyright',
    }
    for _, client in ipairs(clients) do
        if client.settings then
            ---@diagnostic disable-next-line:param-type-mismatch
            client.settings.python = vim.tbl_deep_extend('force', client.settings.python or {}, { pythonPath = path })
        else
            client.config.settings =
                vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
        end
        client:notify('workspace/didChangeConfiguration', {})
    end
end

autocmd('User', {
    group = my_augroup,
    desc = 'set python path',
    pattern = 'PythonEnvActivate',
    callback = function(event)
        set_python_path(event.data.venv_path .. '/bin/python3')
    end,
})

autocmd('User', {
    group = my_augroup,
    pattern = 'CondaEnvActivate',
    desc = 'set python path',
    callback = function(event)
        set_python_path(event.data.conda_env_path .. '/bin/python3')
    end,
})

M.edit_src_wincmd = function(buf, orig_buf)
    local filename = vim.fn.fnamemodify(api.nvim_buf_get_name(orig_buf), ':t')
    local ft = api.nvim_get_option_value('filetype', { buf = buf })
    if ft == nil or ft == '' then
        ft = 'editsrc'
    end

    vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        row = math.floor(vim.o.lines * 0.2),
        col = math.floor(vim.o.columns * 0.2),
        width = math.floor(vim.o.columns * 0.6),
        height = math.floor(vim.o.lines * 0.6),
        style = 'minimal',
        title = filename .. ':' .. ft,
        border = 'rounded',
        title_pos = 'center',
        zindex = 10, -- low priority
    })
end

local edit_src_guess_ft_functions = {
    function(content)
        if content:find '^%s*--sql' then
            return 'sql'
        elseif content:find '^%s*--SQL' then
            return 'sql'
        elseif content:find '^%s*/\\*.*sql.*\\*/' then
            return 'sql'
        elseif content:find '^%s*/\\*.*SQL.*\\*/' then
            return 'sql'
        else
            return nil
        end
    end,
    function(content)
        if content:find '^%s*# python' then
            return 'python'
        else
            return nil
        end
    end,
}

local function edit_src_commit_change(bufnr, orig_buf, start_row, start_col, end_row, end_col)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    vim.schedule(function()
        api.nvim_buf_set_text(orig_buf, start_row, start_col, end_row, end_col, lines)
    end)
    vim.cmd('bwipeout! ' .. bufnr)
end

local function edit_markdown_code_block()
    local bufnr = api.nvim_get_current_buf()
    local cursor_pos = api.nvim_win_get_cursor(0)
    local row = cursor_pos[1] - 1

    local query = vim.treesitter.query.parse(
        'markdown',
        [[
        (fenced_code_block
            (info_string (language) @lang)
            (code_fence_content) @content
        ) @block
    ]]
    )

    local parser = vim.treesitter.get_parser(bufnr, 'markdown')
    ---@diagnostic disable-next-line: need-check-nil
    local tree = parser:parse()[1]
    local root = tree:root()

    for _, match, _ in query:iter_matches(root, bufnr, 0, -1) do
        local code_lang_node = match[1][1]
        local content_node = match[2][1]
        local block_node = match[3][1]

        local block_row_start, _, block_row_end, _ = block_node:range()

        if row >= block_row_start and row <= block_row_end then
            local code_lang = vim.treesitter.get_node_text(code_lang_node, bufnr)

            -- NOTE: setting the buffer as non-scratch is to ensure lsp can be
            -- activated in the temp buffer, since lsp will not activate on scratch
            -- buffer.
            local buf = api.nvim_create_buf(true, false)
            if code_lang and code_lang ~= '' then
                api.nvim_set_option_value('filetype', code_lang, { buf = buf })
            end
            -- Setting buftype to nofile is to prevent from LSP complaining about it
            -- cannot find a file corresponding to the buffer.
            api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
            -- when the window is closed, destroy the temporary buffer
            -- automatically.
            api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

            local code_content = vim.treesitter.get_node_text(content_node, bufnr)
            api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(code_content, '\n'))

            M.edit_src_wincmd(buf, bufnr)

            bufmap(buf, 'n', '<LocalLeader>c', '', {
                desc = 'commit change to original file',
                callback = function()
                    local content_start_row, _, content_end_row, _ = content_node:range()
                    edit_src_commit_change(buf, bufnr, content_start_row, 0, content_end_row - 1, -1)
                end,
            })

            bufmap(buf, 'n', '<LocalLeader>k', '<cmd>bwipeout<cr>', {
                desc = 'discard change',
            })

            return
        end
    end

    vim.notify 'cursor not in a markdown code block'
end

local function edit_src_in_dedicated_buffer()
    local node = vim.treesitter.get_node()
    if not node then
        vim.notify 'not a valid treesitter node'
        return
    end

    if node:type() ~= 'string_content' then
        vim.notify 'not a string node'
        return
    end

    local orig_buf = api.nvim_get_current_buf()
    local content = vim.treesitter.get_node_text(node, 0)

    local start_row, start_col, end_row, end_col = node:range()
    local ft

    for _, func in ipairs(edit_src_guess_ft_functions) do
        ft = func(content)
        if ft then
            break
        end
    end

    -- NOTE: setting the buffer as non-scratch is to ensure lsp can be
    -- activated in the temp buffer, since lsp will not activate on scratch
    -- buffer.
    local buf = api.nvim_create_buf(true, false)
    if ft then
        api.nvim_set_option_value('filetype', ft, { buf = buf })
    end
    -- Setting buftype to nofile is to prevent from LSP complaining about it
    -- cannot find a file corresponding to the buffer.
    api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
    -- when the window is closed, destroy the temporary buffer
    -- automatically.
    api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

    api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, '\n'))

    M.edit_src_wincmd(buf, orig_buf)

    bufmap(buf, 'n', '<LocalLeader>c', '', {
        desc = 'commit change to original file',
        callback = function()
            edit_src_commit_change(buf, orig_buf, start_row, start_col, end_row, end_col)
        end,
    })

    bufmap(buf, 'n', '<LocalLeader>k', '<cmd>bwipeout<cr>', {
        desc = 'discard change',
    })
end

autocmd('FileType', {
    pattern = 'python',
    group = my_augroup,
    desc = 'Add edit src keymap to python',
    callback = function()
        bufmap(0, 'n', "<LocalLeader>'", '', {
            desc = 'edit src under cursor in a dedicated buffer',
            callback = edit_src_in_dedicated_buffer,
        })
    end,
})

autocmd('FileType', {
    pattern = { 'markdown', 'quarto', 'rmd' },
    group = my_augroup,
    desc = 'Add edit src keymap to markdown',
    callback = function()
        bufmap(0, 'n', "<LocalLeader>'", '', {
            desc = 'edit code block under cursor in a dedicated buffer',
            callback = edit_markdown_code_block,
        })
    end,
})

return M
