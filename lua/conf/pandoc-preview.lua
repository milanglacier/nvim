local M = {}

M.config = {
    pandoc_cmd = 'pandoc',
    pandoc_args = {},
    template_file = vim.fn.stdpath 'config' .. '/assets/pandoc-preview-template.html',
}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local bufmap = vim.api.nvim_buf_set_keymap

M.enabled_fts = {
    'markdown',
    'quarto',
    'rmd',
    'org',
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})

    if M.config.template_file == false then
        M.config.template_file = nil
    end
end

local function create_temp_file(filename)
    -- get the directory of current buffer
    local current_dir = vim.fn.fnamemodify(filename, ':p:h')
    local filename_without_extension = vim.fn.fnamemodify(filename, ':t:r')
    return current_dir .. '/' .. filename_without_extension .. '.tmp.html'
end

local function build_pandoc_command(filename, temp_file)
    local pandoc_args = {
        M.config.pandoc_cmd,
        '--to=html5',
        '--standalone',
    }

    if M.config.template_file then
        table.insert(pandoc_args, '--template')
        table.insert(pandoc_args, M.config.template_file)
    end

    vim.list_extend(pandoc_args, M.config.pandoc_args)
    table.insert(pandoc_args, filename)
    table.insert(pandoc_args, '-o')
    table.insert(pandoc_args, temp_file)
    return pandoc_args
end

function M.preview(buf)
    if not vim.tbl_contains(M.enabled_fts, vim.bo[buf].ft) then
        vim.notify 'Unsupported filetype'
        return
    end

    local filename = vim.api.nvim_buf_get_name(buf)

    if not (filename ~= '' and vim.fn.filereadable(filename) == 1) then
        vim.notify 'Not on a file buffer'
        return
    end

    if vim.fn.executable(M.config.pandoc_cmd) == 0 then
        vim.notify 'Pandoc is not installed'
        return
    end

    if M.config.template_file and vim.fn.filereadable(M.config.template_file) == 0 then
        vim.notify('Pandoc preview template is missing: ' .. M.config.template_file)
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

        vim.ui.open(temp_file)

        -- delete the file after the html has been opened
        vim.defer_fn(function()
            vim.fn.delete(temp_file)
        end, 3000)
    end)
end

autocmd('FileType', {
    pattern = M.enabled_fts,
    group = my_augroup,
    desc = 'setup pandoc preview command',
    callback = function()
        bufmap(0, 'n', '<LocalLeader>mp', '', {
            callback = function()
                M.preview(0)
            end,
            desc = 'preview file in html',
        })
    end,
})

return M
