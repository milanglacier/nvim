local M = {}
M.load = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local command = vim.api.nvim_create_user_command
local bufmap = vim.api.nvim_buf_set_keymap

local lazy = require 'lazy'

local function opts_desc(opts)
    return {
        desc = opts[1],
        callback = opts[2],
    }
end

function M.textobj_code_chunk(
    around_or_inner,
    start_pattern,
    end_pattern,
    has_same_start_end_pattern,
    is_in_visual_mode
)
    -- send `<ESC>` key to clear visual marks such that we can update the
    -- visual range.
    if is_in_visual_mode then
        vim.api.nvim_feedkeys('\27', 'nx', false)
    end

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
        if around_or_inner == 'i' then
            vim.api.nvim_win_set_cursor(0, { chunk_start + 1, 0 })
            local internal_length = chunk_end - chunk_start - 2
            if internal_length == 0 then
                vim.cmd.normal { 'V', bang = true }
            elseif internal_length > 0 then
                vim.cmd.normal { 'V' .. internal_length .. 'j', bang = true }
            end
        end

        if around_or_inner == 'a' then
            vim.api.nvim_win_set_cursor(0, { chunk_start, 0 })
            local chunk_length = chunk_end - chunk_start
            vim.cmd.normal { 'V' .. chunk_length .. 'j', bang = true }
        end
    end
end

autocmd('FileType', {
    pattern = { 'rmd', 'quarto' },
    group = my_augroup,
    desc = 'set rmarkdown code chunk textobj',
    callback = function()
        bufmap(0, 'o', 'ac', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '```{.+}', '^```$')
            end,
        })
        bufmap(0, 'o', 'ic', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '```{.+}', '^```$')
            end,
        })

        bufmap(0, 'x', 'ac', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '```{.+}', '^```$', false, true)
            end,
        })

        bufmap(0, 'x', 'ic', '', {
            silent = true,
            desc = 'rmd/quarto code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '```{.+}', '^```$', false, true)
            end,
        })
    end,
})

autocmd('FileType', {
    pattern = { 'r', 'python' },
    group = my_augroup,
    desc = 'set r, python code chunk textobj',
    callback = function()
        bufmap(0, 'o', 'a<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '^# ?%%%%.*', '^# ?%%%%.*', true)
                -- # %%xxxxx or #%%xxxx
            end,
        })
        bufmap(0, 'o', 'i<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '^# ?%%%%.*', '^# ?%%%%.*', true)
            end,
        })

        bufmap(0, 'x', 'a<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '^# ?%%%%.*', '^# ?%%%%.*', true, true)
            end,
        })

        bufmap(0, 'x', 'i<Leader>c', '', {
            silent = true,
            desc = 'code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '^# ?%%%%.*', '^# ?%%%%.*', true, true)
            end,
        })

        bufmap(0, 'o', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '# COMMAND ----------', '# COMMAND ----------', true)
            end,
        })
        bufmap(0, 'o', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '# COMMAND ----------', '# COMMAND ----------', true)
            end,
        })

        bufmap(0, 'x', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '# COMMAND ----------', '# COMMAND ----------', true, true)
            end,
        })

        bufmap(0, 'x', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '# COMMAND ----------', '# COMMAND ----------', true, true)
            end,
        })
    end,
})

autocmd('FileType', {
    pattern = { 'sql' },
    group = my_augroup,
    desc = 'set sql code chunk textobj',
    callback = function()
        bufmap(0, 'o', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '-- COMMAND ----------', '-- COMMAND ----------', true)
            end,
        })
        bufmap(0, 'o', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '-- COMMAND ----------', '-- COMMAND ----------', true)
            end,
        })

        bufmap(0, 'x', 'am', '', {
            silent = true,
            desc = 'databricks code chunk text object a',
            callback = function()
                M.textobj_code_chunk('a', '-- COMMAND ----------', '-- COMMAND ----------', true, true)
            end,
        })

        bufmap(0, 'x', 'im', '', {
            silent = true,
            desc = 'databricks code chunk text object i',
            callback = function()
                M.textobj_code_chunk('i', '-- COMMAND ----------', '-- COMMAND ----------', true, true)
            end,
        })
    end,
})

autocmd('FileType', {
    group = my_augroup,
    pattern = { 'r', 'rmd', 'quarto' },
    desc = 'set r, rmd, and quarto keyword pattern to include .',
    callback = function()
        vim.bo.iskeyword = vim.bo.iskeyword .. ',.'
    end,
})

command('CondaActivateEnv', function(options)
    if vim.fn.executable 'conda' == 0 then
        vim.notify 'conda not found'
        return
    end

    vim.cmd.CondaDeactivate()

    local conda_info = vim.json.decode(vim.fn.system 'conda info --json')
    M.conda_info = conda_info

    if options.args ~= '' then
        M.conda_current_env_path = options.args
    else
        M.conda_current_env_path = conda_info.root_prefix
    end

    -- if conda_current_env_path is found in $PATH, do nothing, else prepend it to $PATH
    if not string.find(vim.env.PATH, M.conda_current_env_path .. '/bin') then
        vim.env.PATH = M.conda_current_env_path .. '/bin:' .. vim.env.PATH
    end

    vim.env.CONDA_PREFIX = M.conda_current_env_path
    vim.env.CONDA_DEFAULT_ENV = vim.fn.fnamemodify(M.conda_current_env_path, ':t')
    vim.env.CONDA_SHLVL = 1
    vim.env.CONDA_PROMPT_MODIFIER = '(' .. vim.env.CONDA_DEFAULT_ENV .. ') '

    vim.notify 'conda env activated'
end, {
    nargs = '?',
    complete = function(_, _, _)
        if vim.fn.executable 'conda' == 0 then
            return {}
        end

        local conda_envs

        -- use cache to speed up completion
        if M.conda_info then
            conda_envs = M.conda_info.envs
        else
            M.conda_info = vim.json.decode(vim.fn.system 'conda info --json')
            conda_envs = M.conda_info.envs
        end

        return conda_envs
    end,
})

command('CondaDeactivate', function(_)
    if vim.fn.executable 'conda' == 0 then
        vim.notify 'conda not found'
        return
    end

    local conda_info = vim.json.decode(vim.fn.system 'conda info --json')

    if not M.conda_current_env_path then
        M.conda_current_env_path = conda_info.root_prefix
    end

    local env_split = vim.split(vim.env.PATH, ':')
    for idx, path in ipairs(env_split) do
        if path == M.conda_current_env_path .. '/bin' then
            table.remove(env_split, idx)
        end
    end
    vim.env.PATH = table.concat(env_split, ':')
    vim.env.CONDA_PREFIX = nil
    vim.env.CONDA_DEFAULT_ENV = nil
    vim.env.CONDA_SHLVL = 0
    vim.env.CONDA_PROMPT_MODIFIER = nil
    M.conda_current_env_path = nil

    vim.notify 'conda env deactivated'
end, {
    desc = [[This command deactivates a conda environment. Note that after the
execution, the conda env will be completely cleared (i.e. without base
environment activated).]],
})

command('PyVenvActivate', function(options)
    vim.cmd.PyVenvDeactivate()
    local path = options.args
    path = vim.fn.fnamemodify(path, ':p:h')
    -- get the absolute path, and remove the trailing "/"
    path = string.gsub(path, '/bin$', '')
    -- remove the trailing '/bin'
    vim.env.VIRTUAL_ENV = path
    path = path .. '/bin'
    -- remove the trailing `/` in the string.
    M.pyvenv_current_env_path = path
    vim.env.PATH = path .. ':' .. vim.env.PATH
end, {
    nargs = 1,
    complete = 'dir',
    desc = [[This command activates a python venv. The path to the python virtual environment may include "/bin/" or not.]],
})

command('PyVenvDeactivate', function(_)
    if not M.pyvenv_current_env_path then
        return
    end
    local env_split = vim.split(vim.env.PATH, ':')
    for idx, path in ipairs(env_split) do
        if path == M.pyvenv_current_env_path then
            table.remove(env_split, idx)
        end
    end
    vim.env.PATH = table.concat(env_split, ':')
    vim.env.VIRTUAL_ENV = nil
    M.pyvenv_current_env_path = nil
end, {
    desc = 'This command deactivates a python venv.',
})

M.load.pandoc = function()
    vim.filetype.add {
        extension = {
            md = 'markdown.pandoc',
        },
    }

    vim.g.r_indent_align_args = 0
    vim.g.r_indent_ess_comments = 0
    vim.g.r_indent_ess_compatible = 0

    vim.g['pandoc#syntax#codeblocks#embeds#langs'] = { 'python', 'R=r', 'r', 'bash=sh', 'json' }

    lazy.load { plugins = { 'vim-pandoc-syntax', 'vim-rmarkdown', 'quarto-vim' } }
end

M.load.vimtex = function()
    vim.g.vimtex_mappings_enabled = 0
    vim.g.vimtex_imaps_enabled = 0
    vim.g.tex_flavor = 'latex'
    vim.g.vimtex_enabled = 1
    vim.g.vimtex_quickfix_mode = 0 -- don't open quickfix list automatically
    vim.g.vimtex_delim_toggle_mod_list = {
        { '\\bigl', '\\bigr' },
        { '\\Bigl', '\\Bigr' },
        { '\\biggl', '\\biggr' },
        { '\\Biggl', '\\Biggr' },
    }
    if vim.fn.has 'mac' == 1 then
        vim.g.vimtex_view_method = 'skim'
        vim.g.vimtex_view_skim_sync = 1
        vim.g.vimtex_view_skim_activate = 1
    end

    lazy.load { plugins = { 'vimtex' } }

    autocmd('FileType', {
        pattern = 'tex',
        group = my_augroup,
        desc = 'set keymap for tex',
        callback = function()
            local set_bufmap = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, {
                    buffer = true,
                    noremap = false,
                    silent = true,
                    desc = desc,
                })
            end

            --- nvim-treesitter-textobjects have conflicted
            -- textobj map with vimtex
            -- (and both of them are buffer local triggerd at FileType event).
            -- Defer mapping vimtex specific texobj maps
            -- to override nvim-treesitter-textobjects' map
            local defer_bufmap = function(...)
                local param_list = { ... }
                vim.defer_fn(function()
                    set_bufmap(unpack(param_list))
                end, 1000)
            end

            set_bufmap('n', '<LocalLeader>lt', '<Plug>(vimtex-toc-toggle)')
            set_bufmap('n', '<LocalLeader>ll', '<Plug>(vimtex-compile)')
            set_bufmap('n', '<LocalLeader>lc', '<Plug>(vimtex-clean)')
            set_bufmap('n', '<LocalLeader>lv', '<Plug>(vimtex-view)')
            set_bufmap('n', '<LocalLeader>lk', '<Plug>(vimtex-stop)')
            set_bufmap('n', '<LocalLeader>lm', '<Plug>(vimtex-toggle-main)')
            set_bufmap('n', '<LocalLeader>la', '<Plug>(vimtex-context-menu)')
            set_bufmap('n', '<LocalLeader>lo', '<Plug>(vimtex-compile-output)')
            set_bufmap('n', '<LocalLeader>ss', '<Plug>(vimtex-env-surround-line)')
            set_bufmap('n', '<LocalLeader>s', '<Plug>(vimtex-env-surround-operator)')
            set_bufmap('x', '<LocalLeader>s', '<Plug>(vimtex-env-surround-visual)')

            set_bufmap('n', 'dse', '<plug>(vimtex-env-delete)')
            set_bufmap('n', 'dsc', '<plug>(vimtex-cmd-delete)')
            set_bufmap('n', 'ds$', '<plug>(vimtex-env-delete-math)')
            set_bufmap('n', 'dsd', '<plug>(vimtex-delim-delete)')
            set_bufmap('n', 'cse', '<plug>(vimtex-env-change)')
            set_bufmap('n', 'csc', '<plug>(vimtex-cmd-change)')
            set_bufmap('n', 'cs$', '<plug>(vimtex-env-change-math)')
            set_bufmap('n', 'csd', '<plug>(vimtex-delim-change-math)')
            set_bufmap({ 'n', 'x' }, '<LocalLeader>tf', '<plug>(vimtex-cmd-toggle-frac)')
            set_bufmap('n', '<LocalLeader>tc*', '<plug>(vimtex-cmd-toggle-star)')
            set_bufmap('n', '<LocalLeader>te*', '<plug>(vimtex-env-toggle-star)')
            set_bufmap('n', '<LocalLeader>t$', '<plug>(vimtex-env-toggle-math)')
            set_bufmap({ 'n', 'x' }, '<LocalLeader>td', '<plug>(vimtex-delim-toggle-modifier)')
            set_bufmap({ 'n', 'x' }, '<LocalLeader>tD', '<plug>(vimtex-delim-toggle-modifier-reverse)')
            set_bufmap({ 'n', 'x' }, '<LocalLeader>c', '<plug>(vimtex-cmd-create)')

            defer_bufmap({ 'x', 'o' }, 'ac', '<plug>(vimtex-ac)', 'vimtex texobj around command')
            defer_bufmap({ 'x', 'o' }, 'ic', '<plug>(vimtex-ic)', 'vimtex texobj in command')
            set_bufmap({ 'x', 'o' }, 'ad', '<plug>(vimtex-ad)', 'vimtex texobj around delim')
            set_bufmap({ 'x', 'o' }, 'id', '<plug>(vimtex-id)', 'vimtex texobj in delim')
            defer_bufmap({ 'x', 'o' }, 'ae', '<plug>(vimtex-ae)', 'vimtex texobj around env')
            defer_bufmap({ 'x', 'o' }, 'ie', '<plug>(vimtex-ie)', 'vimtex texobj in env')
            set_bufmap({ 'x', 'o' }, 'a$', '<plug>(vimtex-a$)', 'vimtex texobj around math')
            set_bufmap({ 'x', 'o' }, 'i$', '<plug>(vimtex-i$)', 'vimtex texobj in math')
            set_bufmap({ 'x', 'o' }, 'aS', '<plug>(vimtex-aP)', 'vimtex texobj around section')
            set_bufmap({ 'x', 'o' }, 'iS', '<plug>(vimtex-iP)', 'vimtex texobj in section')
            defer_bufmap({ 'x', 'o' }, 'al', '<plug>(vimtex-am)', 'vimtex texobj around item')
            defer_bufmap({ 'x', 'o' }, 'il', '<plug>(vimtex-im)', 'vimtex texobj in item')

            set_bufmap({ 'n', 'x', 'o' }, '%', '<plug>(vim-tex-%)')

            set_bufmap({ 'n', 'x', 'o' }, ']]', '<plug>(vimtex-]])', 'vimtex motion next start of section')
            set_bufmap({ 'n', 'x', 'o' }, '][', '<plug>(vimtex-][)', 'vimtex motion next end of section')
            set_bufmap({ 'n', 'x', 'o' }, '[]', '<plug>(vimtex-[])', 'vimtex motion prev start of section')
            set_bufmap({ 'n', 'x', 'o' }, '[[', '<plug>(vimtex-[[)', 'vimtex motion prev end of section')
            defer_bufmap({ 'n', 'x', 'o' }, ']e', '<plug>(vimtex-]m)', 'vimtex motion next start of env')
            defer_bufmap({ 'n', 'x', 'o' }, ']E', '<plug>(vimtex-]M)', 'vimtex motion next end of env')
            defer_bufmap({ 'n', 'x', 'o' }, '[e', '<plug>(vimtex-[m)', 'vimtex motion prev start of env')
            defer_bufmap({ 'n', 'x', 'o' }, '[E', '<plug>(vimtex-[M)', 'vimtex motion prev end of env')
            set_bufmap({ 'n', 'x', 'o' }, ']m', '<plug>(vimtex-]n)', 'vimtex motion next start of math')
            set_bufmap({ 'n', 'x', 'o' }, ']M', '<plug>(vimtex-]N)', 'vimtex motion next end of math')
            set_bufmap({ 'n', 'x', 'o' }, '[m', '<plug>(vimtex-[n)', 'vimtex motion prev start of math')
            set_bufmap({ 'n', 'x', 'o' }, '[M', '<plug>(vimtex-[N)', 'vimtex motion prev end of math')
            defer_bufmap({ 'n', 'x', 'o' }, ']f', '<plug>(vimtex-]r)', 'vimtex motion next start of frame')
            defer_bufmap({ 'n', 'x', 'o' }, ']F', '<plug>(vimtex-]R)', 'vimtex motion next end of frame')
            defer_bufmap({ 'n', 'x', 'o' }, '[f', '<plug>(vimtex-[r)', 'vimtex motion prev start of frame')
            defer_bufmap({ 'n', 'x', 'o' }, '[F', '<plug>(vimtex-[R)', 'vimtex motion prev end of frame')

            set_bufmap('n', 'K', '<plug>(vimtex-doc-package)')
        end,
    })
end

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

M.load.nvimr = function()
    vim.g.R_assign = 0
    vim.g.R_app = 'radian'
    vim.g.R_cmd = 'R'
    vim.g.R_args = {}
    vim.g.R_user_maps_only = 1
    vim.g.R_hl_term = 0
    vim.g.R_esc_term = 0
    vim.g.R_buffer_opts = 'buflisted' -- nvimr prevents repl window to be automatically resized, reenable it
    vim.g.R_objbr_place = 'console,right' -- show object browser at the right of the console
    vim.g.R_nvim_wd = 1
    vim.g.R_rmdchunk = 0
    vim.g.R_filetypes = { 'r', 'rmd', 'rrst', 'rnoweb', 'rhelp' }
    -- don't use quarto with nvimr

    lazy.load { plugins = { 'Nvim-R' } }

    autocmd('FileType', {
        pattern = { 'r', 'rmd' },
        group = my_augroup,
        desc = 'set nvim-r keymap',
        callback = function()
            bufmap(0, 'n', '<Localleader>rs', '<Plug>RStart', opts_desc { 'R Start' })
            bufmap(0, 'n', '<Localleader>rq', '<Plug>RStop', opts_desc { 'R Stop' })
            bufmap(0, 'n', '<Localleader>rc', '<Plug>RClearConsole', opts_desc { 'R Clear' })
            bufmap(0, 'n', '<Localleader>rr', '<nop>', {})
            bufmap(0, 'n', '<Localleader>rh', '<nop>', {})
            bufmap(0, 'n', '<Localleader>rf', '<nop>', {})
            bufmap(0, 'n', '<Localleader>rw', '<nop>', {})
            bufmap(0, 'n', '<Localleader>ra', '<nop>', {})

            bufmap(0, 'n', '<Localleader>ss', '<Plug>RSendLine', opts_desc { 'R Send Current Line' })
            bufmap(0, 'n', '<Localleader>sm', '<Plug>RSendMBlock', opts_desc { 'R Send Between Two Marks' })
            bufmap(0, 'n', '<Localleader>sf', '<Plug>RSendFile', opts_desc { 'R Send Files' })
            bufmap(0, 'n', '<Localleader>s', '<Plug>RSendMotion', opts_desc { 'R Send Motion' })
            bufmap(0, 'n', '<Localleader>s<CR>', '<nop>', {})
            bufmap(0, 'v', '<Localleader>s', '<Plug>RSendSelection', opts_desc { 'R Send Selected Lines' })

            bufmap(0, 'n', '<Localleader>oh', '<Plug>RHelp', opts_desc { 'R object Help' })
            bufmap(0, 'n', '<Localleader>op', '<Plug>RObjectPr', opts_desc { 'R object Print' })
            bufmap(0, 'n', '<Localleader>os', '<Plug>RObjectStr', opts_desc { 'R object str' })
            bufmap(0, 'n', '<Localleader>oS', '<Plug>RSummary', opts_desc { 'R object summary' })
            bufmap(0, 'n', '<Localleader>on', '<Plug>RObjectNames', opts_desc { 'R object names' })
            bufmap(0, 'n', '<Localleader>oo', '<Plug>RUpdateObjBrowser', opts_desc { 'R object viewer open' })
            bufmap(0, 'n', '<Localleader>or', '<Plug>ROpenLists', opts_desc { 'R object open all lists' })
            bufmap(0, 'n', '<Localleader>om', '<Plug>RCloseLists', opts_desc { 'R object close all lists' })

            bufmap(0, 'n', '<Localleader>dt', '<Plug>RViewDF', opts_desc { 'R dataframe new tab' })
            bufmap(0, 'n', '<Localleader>ds', '<Plug>RViewDFs', opts_desc { 'R dataframe hsplit' })
            bufmap(0, 'n', '<Localleader>dh', '<Plug>RViewDFa', opts_desc { 'R dataframe head' })
            bufmap(0, 'n', '<Localleader>dv', '<Plug>RViewDFv', opts_desc { 'R dataframe vsplit' })
        end,
    })
end

M.load.quarto = function()
    autocmd('FileType', {
        pattern = 'quarto',
        group = my_augroup,
        desc = 'enable multip language support for quarto',
        callback = function()
            vim.defer_fn(function()
                require('otter').activate({ 'r', 'python' }, true)
                -- defer activation, otherwise those hidden buffer
                -- i.e R, python will not be activated (they are virtual buffer).
            end, 500)
        end,
    })
end

M.load.vimtex()
M.load.pandoc()
-- M.load.nvimr()
M.load.quarto()

return M
