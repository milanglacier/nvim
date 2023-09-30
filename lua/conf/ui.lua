local M = {}
M.load = {}

local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local set_hl = vim.api.nvim_set_hl

M.load.lualine = function()
    -- Override 'encoding': Don't display if encoding is UTF-8.
    local encoding = function()
        local ret, _ = (vim.bo.fenc or vim.go.enc):gsub('^utf%-8$', '')
        return ret
    end

    local fileformat = function()
        local ret, _ = vim.bo.fileformat:gsub('^unix$', '')
        if ret == 'dos' then
            ret = ''
        end
        return ret
    end

    -- current file is lua/conf/ui.lua
    -- current working directory is ~/.config/nvim
    -- this function will return "nvim"
    --
    ---@return string project_name
    local project_name = function()
        -- don't use pattern matching, just plain match
        if vim.fn.expand('%:p'):find(vim.fn.getcwd(), nil, true) then
            -- if the absolute path of current file is a sub directory of cwd
            return ' ' .. vim.fn.fnamemodify('%', ':p:h:t')
        else
            return ''
        end
    end

    local file_status_symbol = {
        modified = '',
        readonly = '',
        new = '',
        unnamed = '󰽤',
    }

    local lualine = require 'lualine'

    local diagnostics_sources = require('lualine.components.diagnostics.sources').sources

    diagnostics_sources.get_diagnostics_in_current_root_dir = function()
        local buffers = vim.api.nvim_list_bufs()
        local severity = vim.diagnostic.severity
        local cwd = vim.loop.cwd()

        local function dir_is_parent_of_buf(buf, dir)
            local filename = vim.api.nvim_buf_get_name(buf)
            if vim.fn.filereadable(filename) == 0 then
                return false
            end

            for path in vim.fs.parents(filename) do
                if dir == path then
                    return true
                end
            end
            return false
        end

        local function get_num_of_diags_in_buf(severity_level, buf)
            local count = vim.diagnostic.get(buf, { severity = severity_level })
            return vim.tbl_count(count)
        end

        local diagnostics_of_error = 0
        local diagnostics_of_warn = 0
        local diagnostics_of_info = 0
        local diagnostics_of_hint = 0

        for _, buf in ipairs(buffers) do
            if dir_is_parent_of_buf(buf, cwd) then
                diagnostics_of_error = diagnostics_of_error + get_num_of_diags_in_buf(severity.ERROR, buf)
                diagnostics_of_warn = diagnostics_of_warn + get_num_of_diags_in_buf(severity.WARN, buf)
                diagnostics_of_info = diagnostics_of_info + get_num_of_diags_in_buf(severity.INFO, buf)
                diagnostics_of_hint = diagnostics_of_hint + get_num_of_diags_in_buf(severity.HINT, buf)
            end
        end

        return diagnostics_of_error, diagnostics_of_warn, diagnostics_of_info, diagnostics_of_hint
    end

    lualine.setup {
        options = {
            icons_enabled = true,
            theme = 'auto',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            always_divide_middle = false,
            disabled_filetypes = {
                winbar = {
                    'aerial',
                    'NvimTree',
                    'starter',
                    'Trouble',
                    'qf',
                    'NeogitStatus',
                    'NeogitCommitMessage',
                    'NeogitPopup',
                },
                statusline = {
                    'starter',
                },
            },
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                'branch',
                project_name,
                M.get_workspace_diff,
            },
            lualine_c = { { 'filename', path = 1, symbols = file_status_symbol }, { 'searchcount' } }, -- relative path
            lualine_x = {
                { 'diagnostics', sources = { 'get_diagnostics_in_current_root_dir' } },
                encoding,
                fileformat,
                'filetype',
            },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
        },
        tabline = {
            lualine_a = {
                { 'filetype', icon_only = true },
            },
            lualine_b = {
                { 'tabs', mode = 2, max_length = vim.o.columns },
                {
                    function()
                        vim.o.showtabline = 1
                        return ''
                        --HACK: lualine will set &showtabline to 2 if you have configured
                        --lualine for displaying tabline. We want to restore the default
                        --behavior here.
                    end,
                },
            },
        },
        winbar = {
            lualine_a = {
                { 'filetype', icon_only = true },
                { 'filename', path = 0, symbols = file_status_symbol },
            },
            lualine_c = { M.winbar_symbol },
            lualine_x = {
                function()
                    return ' '
                end,
                -- this is to avoid annoying highlight (high contrast color)
                -- when no winbar_symbol, diagnostics and diff is available.
                { 'diagnostics', sources = { 'nvim_diagnostic' } },
                'diff',
            },
        },
        inactive_winbar = {
            lualine_a = {
                { 'filetype', icon_only = true },
                { 'filename', path = 0, symbols = file_status_symbol },
            },
            lualine_x = {
                { 'diagnostics', sources = { 'nvim_diagnostic' } },
                'diff',
            },
        },
        extensions = { 'aerial', 'nvim-tree', 'quickfix', 'toggleterm' },
    }
end

M.load.notify = function()
    vim.notify = require 'notify'

    require('notify').setup {
        max_width = 45,
        max_height = 20,
    }

    local opts = { noremap = true, silent = true }
    local keymap = vim.api.nvim_set_keymap
    keymap('n', '<leader>fn', '<cmd>Telescope notify<cr>', opts)
end

M.load.devicons = function()
    require('nvim-web-devicons').setup()
end

M.load.trouble = function()
    require('trouble').setup {
        mode = 'quickfix',
        action_keys = {
            close = 'q', -- close the list
            cancel = { '<esc>', '<c-e>' }, -- cancel the preview and get back to your last window / buffer / cursor
            refresh = 'r', -- manually refresh
            jump = { '<cr>', '<tab>' }, -- jump to the diagnostic or open / close folds
            open_split = { '<c-x>', '<c-s>' }, -- open buffer in new split
            open_vsplit = { '<c-v>' }, -- open buffer in new vsplit
            open_tab = { '<c-t>' }, -- open buffer in new tab
            jump_close = { 'o' }, -- jump to the diagnostic and close the list
            toggle_mode = 'm', -- toggle between "workspace" and "document" diagnostics mode
            toggle_preview = 'P', -- toggle auto_preview
            hover = { 'K', 'gh' }, -- opens a small popup with the full multiline message
            preview = 'p', -- preview the diagnostic location
            close_folds = { 'zM', 'zm' }, -- close all folds
            open_folds = { 'zR', 'zr' }, -- open all folds
            toggle_fold = { 'zA', 'za' }, -- toggle fold of current file
            previous = 'k', -- preview item
            next = 'j', -- next item
        },
    }

    local keymap = vim.api.nvim_set_keymap
    local opts = { noremap = true, silent = true }

    keymap('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', opts)
    keymap('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', opts)
    keymap('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', opts)
    keymap('n', '<leader>xq', [[<cmd>lua require 'conf.ui'.reopen_qflist_by_trouble()<cr>]], opts)
    keymap('n', '<leader>xr', '<cmd>TroubleToggle lsp_references<cr>', opts)
end

M.load.which_key = function()
    local which_key = require 'which-key'
    which_key.setup {
        triggers = { '<leader>', '<localleader>', 'g', 'z', ']', '[', '`', '"', [[']], '@' },
    }

    which_key.register {
        ['<Leader>f'] = { name = '+find everything', mode = { 'n', 'v' } },
        ['<Leader>l'] = { name = '+language server', mode = { 'n', 'v' } },
        ['<Leader>d'] = { name = '+debugger' },
        ['<Leader>b'] = { name = '+buffer' },
        ['<Leader>w'] = { name = '+window' },
        ['<Leader>e'] = { name = '+explorer' },
        ['<Leader>t'] = { name = '+terminal/toggle' },
        ['<Leader>o'] = { name = '+open/org' },
        ['<Leader>ol'] = { name = '+open/links' },
        ['<Leader>g'] = { name = '+git' },
        ['<Leader>x'] = { name = '+quickfixlist' },
        ['<Leader>c'] = { name = '+chatgpt', mode = { 'n', 'v' } },
        ['<Leader><Tab>'] = { name = '+tab' },
        ['<Leader><space>'] = { name = '+local leader' },
        ['<Leader>m'] = { name = '+misc', mode = { 'n', 'v' } },
        ['<Leader>mm'] = { name = '+markdown' },
        ['<Leader>md'] = { name = '+change directory' },
        [']<Space>'] = { name = '+Additional motions' },
        [']<Space>l'] = { name = '+latex motions' },
        ['[<Space>'] = { name = '+Additional motions' },
        ['[<Space>l'] = { name = '+latex motions' },
    }

    local keymap_for_repl = {}

    keymap_for_repl['<Leader><Space>r'] = { name = '+REPL', buffer = 0 }
    keymap_for_repl['<Leader><Space>s'] = { name = '+send to REPL(motion)', buffer = 0, mode = { 'n', 'v' } }

    autocmd('FileType', {
        group = my_augroup,
        pattern = 'org',
        desc = 'add which key description for org',
        callback = function()
            which_key.register {
                ['<Leader>oi'] = { name = '+org insert', buffer = 0 },
                ['<Leader>ox'] = { name = '+org clock', buffer = 0 },
            }
        end,
    })

    autocmd('FileType', {
        group = my_augroup,
        pattern = { 'r', 'rmd' },
        desc = 'add which key description for r, rmd, quarto',
        callback = function()
            which_key.register {
                ['<Leader><Space>d'] = { name = '+data frame', buffer = 0 },
                ['<Leader><Space>o'] = { name = '+object', buffer = 0 },
                ['<Leader><Space>r'] = { name = '+REPL', buffer = 0 },
                ['<Leader><Space>s'] = { name = '+send to REPL(motion)', buffer = 0, mode = { 'n', 'v' } },
            }
        end,
    })

    autocmd('FileType', {
        group = my_augroup,
        pattern = 'tex',
        desc = 'add which key description for tex',
        callback = function()
            which_key.register {
                ['<Leader><Space>l'] = { name = '+vimtex', buffer = 0 },
                ['<Leader><Space>s'] = { name = '+vimtex surround', buffer = 0 },
                ['<Leader><Space>t'] = { name = '+vimtex toggle', buffer = 0 },
                ['<Leader><Space>c'] = { name = 'vimtex create cmd', buffer = 0 },
            }
        end,
    })

    autocmd('FileType', {
        pattern = { 'quarto', 'markdown', 'markdown.pandoc', 'rmd', 'python', 'sh', 'REPL' },
        group = my_augroup,
        desc = 'Add which key description for REPL',
        callback = function()
            which_key.register(keymap_for_repl)
        end,
    })
end

M.load.indent_blankline = function()
    require('ibl').setup {
        indent = {
            char = '┆',
        },
        scope = {
            show_start = false,
            show_end = false,
            priority = 1,
            highlight = { 'Type' },
            include = {
                node_type = {
                    ['*'] = { 'if_statement', 'for_statement', 'while_statement' },
                    -- TODO: Honestly, I only care about CURRENT INDENTATION
                    -- LEVEL. I have no idea why the author reimplemented
                    -- everything. the concept of "scope" is particularly
                    -- baffling. it brings nothing but leads to a lot of
                    -- annoyoing things. Thus, I need to add more nodes to be
                    -- considered as scope to mimic "CURRENT INDENTATION LEVEL"
                    -- behavior.
                },
            },
        },
    }
end

M.load.mini_starter = function()
    M.header_verse = {
        [[
Bright star, would I were steadfast as thee art!
 John Keats]],
        [[
For clattering parrots to launch their fleet at sunrise
For April to ignite the African violet
 Derek Walcott]],
        [[
In these poinsettia meadows of her tides,—
Adagios of islands, O my Prodigal,
Complete the dark confessions her veins spell.
 Hart Crane]],
        [[
帝子降兮北渚，目眇眇兮愁予，
袅袅兮秋风，洞庭波兮木叶下。
 《湘夫人》]],
        [[
美人迈兮音尘阙，隔千里兮共明月。
临风叹兮将焉歇，川路长兮不可越！
 《月赋》]],
        [[
浴兰汤兮沐芳，华采衣兮若英。
灵连蜷兮既留，烂昭昭兮未央。
蹇将憺兮寿宫，与日月兮齐光。
 《云中君》]],
        length = 6,
    }

    M.foot_verse = {
        [[
Whispers antiphonal in the azure swing...
 Hart Crane]],
        [[
In the drumming world that dampens your tired eyes
Behind two clouding lenses, sunrise, sunset,
The quiet ravage of diabetes.
 Derek Walcott]],
        [[
What words
Can strangle this deaf moonlight? For we
Are overtaken.
 Hart Crane]],
        [[
搴汀洲兮杜若，将以遗兮远者。
时不可兮骤得，聊逍遥兮容与！
 《湘夫人》]],
        [[
月既没兮露欲晞，岁方晏兮无与归。
佳期可以还，微霜沾人衣。
 《月赋》]],
        [[
雷填填兮雨冥冥，猨啾啾兮狖夜鸣。
风飒飒兮木萧萧，思公子兮徒离忧。
 《山鬼》]],
        length = 6,
    }

    local starter = require 'mini.starter'

    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    starter.setup {
        header = M.header_verse[math.random(1, M.header_verse.length)],
        evaluate_single = true,
        items = {
            {
                {
                    action = [[lua require("conf.colorscheme").pick_randomly()]],
                    name = 'pick new theme!',
                    section = 'Appearance',
                },
                {
                    action = [[lua require("conf.ui").change_verses()]],
                    name = 'show new verses!',
                    section = 'Appearance',
                },
                { action = 'Telescope projects', name = 'recent projects', section = 'Telescope' },
                { action = 'Telescope oldfiles', name = 'old files', section = 'Telescope' },
                { action = 'Telescope find_files', name = 'find files', section = 'Telescope' },
                { action = 'Telescope command_history', name = 'command history', section = 'Telescope' },
                { action = 'Telescope jumplist', name = 'jumplist', section = 'Telescope' },
                { name = 'edit new buffer', action = 'enew', section = 'Builtin actions' },
                { name = 'quit Neovim', action = 'qall!', section = 'Builtin actions' },
            },
        },
        content_hooks = {
            starter.gen_hook.adding_bullet(),
            starter.gen_hook.aligning('center', 'center'),
        },
        starter.gen_hook.padding(5, 2),
        footer = M.foot_verse[math.random(1, M.foot_verse.length)],
        query_updaters = [[abcdefhijklmnopqrsuvwxyz]],
    }
end

M.winbar_symbol = function()
    local navic = require 'nvim-navic'

    if navic.is_available() then
        return navic.get_location()
    end

    local winwidth = vim.api.nvim_win_get_width(0)
    local filename = vim.fn.expand '%:.'

    local winbar = filename

    local rest_length = winwidth - #winbar - 3
    local ts_status = ''

    if rest_length > 5 then
        local size = math.floor(rest_length * 0.8)

        ts_status = require('nvim-treesitter').statusline {
            indicator_size = size,
            separator = '  ',
        } or ''

        if ts_status ~= nil and ts_status ~= '' then
            ts_status = ts_status:gsub('%s+', ' ')
        end
    end

    return ts_status
end

M.git_workspace_diff = {}

M.git_workspace_diff_setup = function()
    local function is_a_git_dir()
        local is_git = vim.fn.system 'git rev-parse --is-inside-work-tree' == 'true\n'
        return is_git
    end

    local function compute_workspace_diff(cwd)
        vim.fn.jobstart([[git diff --stat | tail -n 1]], {
            stdout_buffered = true,
            on_stdout = function(_, data, _)
                local changes_raw = data[1]
                changes_raw = string.sub(changes_raw, 1, -2) -- the last character is \n, remove it
                changes_raw = vim.split(changes_raw, ',')

                local changes = ''

                for _, i in pairs(changes_raw) do
                    if i:find 'change' then
                        changes = changes .. ' ' .. i:match '(%d+)'
                    elseif i:find 'insertion' then
                        changes = changes .. ' +' .. i:match '(%d+)'
                    elseif i:find 'deletion' then
                        changes = changes .. ' -' .. i:match '(%d+)'
                    end
                end

                if changes ~= '' then
                    changes = ' ' .. changes
                end

                M.git_workspace_diff[cwd] = changes
            end,
        })
    end

    local function init_workspace_diff()
        local cwd = vim.fn.getcwd()

        if M.git_workspace_diff[cwd] == nil and is_a_git_dir() then
            compute_workspace_diff(cwd)
        end
    end

    local function update_workspace_diff()
        local cwd = vim.fn.getcwd()
        if M.git_workspace_diff[cwd] ~= nil then
            compute_workspace_diff(cwd)
        end
    end

    autocmd('BufEnter', {
        group = my_augroup,
        desc = 'Init the git diff',
        callback = function()
            vim.defer_fn(function()
                init_workspace_diff()
                -- defer this function because project root need to be updated.
            end, 100)
        end,
    })
    autocmd('BufWritePost', {
        group = my_augroup,
        desc = 'Update the git diff',
        callback = function()
            vim.defer_fn(function()
                update_workspace_diff()
            end, 100)
        end,
    })
end

M.get_workspace_diff = function()
    local cwd = vim.fn.getcwd()
    -- don't use pattern matching
    if vim.fn.expand('%:p'):find(cwd, nil, true) then
        -- if the absolute path of current file is a sub directory of cwd
        return M.git_workspace_diff[cwd] or ''
    else
        return ''
    end
end

M.change_verses = function()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    _G.MiniStarter.config.header = M.header_verse[math.random(1, M.header_verse.length)]
    _G.MiniStarter.config.footer = M.foot_verse[math.random(1, M.foot_verse.length)]

    _G.MiniStarter.refresh()
end

M.reopen_qflist_by_trouble = function()
    local windows = vim.api.nvim_list_wins()

    for _, winid in ipairs(windows) do
        local bufid = vim.api.nvim_win_get_buf(winid)
        local buf_filetype = vim.api.nvim_buf_get_option(bufid, 'filetype')
        if buf_filetype == 'qf' then
            vim.api.nvim_win_close(winid, true)
        end
    end
    require('trouble').toggle 'quickfix'
end

M.load.devicons()
M.load.lualine()
M.load.notify()
M.load.trouble()
M.load.which_key()
M.load.indent_blankline()
M.load.mini_starter()
M.git_workspace_diff_setup()

return M
