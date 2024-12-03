local M = {}

M.pandoc_cmd = 'pandoc'

M.pandoc_args = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufmap = vim.api.nvim_buf_set_keymap

local enabled_fts = {
    'markdown',
    'quarto',
    'rmd',
    'org',
}

local function create_temp_file(filename)
    -- get the directory of current buffer
    local current_dir = vim.fn.fnamemodify(filename, ':p:h')
    local filename_without_extension = vim.fn.fnamemodify(filename, ':t:r')
    return current_dir .. '/' .. filename_without_extension .. '.tmp.html'
end

local function build_pandoc_command(filename, temp_file)
    local pandoc_args = vim.deepcopy(M.pandoc_args)

    table.insert(pandoc_args, 1, M.pandoc_cmd)
    table.insert(pandoc_args, filename)
    table.insert(pandoc_args, '-o')
    table.insert(pandoc_args, temp_file)
    return pandoc_args
end

local function preview(buf)
    if not vim.tbl_contains(enabled_fts, vim.bo[buf].ft) then
        vim.notify 'Unsupported filetype'
        return
    end

    local filename = vim.api.nvim_buf_get_name(buf)

    if not (filename ~= '' and vim.fn.filereadable(filename) == 1) then
        vim.notify 'Not on a file buffer'
        return
    end

    if vim.fn.executable(M.pandoc_cmd) == 0 then
        vim.notify 'Pandoc is not installed'
        return
    end

    local temp_file = create_temp_file(filename)

    if not temp_file then
        return
    end

    vim.system(build_pandoc_command(filename, temp_file), { text = true }, function(obj)
        if obj.code ~= 0 then
            vim.notify 'pandoc failed to convert the file to html'
            vim.notify(obj.stderr)
            return
        end

        local is_mac = vim.fn.has 'mac' == 1
        local is_unix = vim.fn.has 'unix' == 1

        if not (is_mac or is_unix) then
            vim.notify 'This command only supports unix and macOS'
            return
        end

        local open = is_mac and 'open' or 'xdg-open'

        vim.system { open, temp_file }

        -- delete the file after the html has been opened
        vim.defer_fn(function()
            vim.fn.delete(temp_file)
        end, 1000)
    end)
end

autocmd('FileType', {
    pattern = enabled_fts,
    group = my_augroup,
    desc = 'setup pandoc preview command',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>mp', '', {
            callback = function()
                preview(0)
            end,
            desc = 'preview file in html',
        })
    end,
})
