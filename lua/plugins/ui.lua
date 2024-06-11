local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup
local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

return {
    {
        'nvim-lualine/lualine.nvim',
        event = 'VeryLazy',
        config = function()
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
                local cwd = vim.uv.cwd()

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

                local n_diagnostics = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }

                for _, buf in ipairs(buffers) do
                    if dir_is_parent_of_buf(buf, cwd) then
                        for _, level in ipairs { 'ERROR', 'WARN', 'INFO', 'HINT' } do
                            n_diagnostics[level] = n_diagnostics[level] + get_num_of_diags_in_buf(severity[level], buf)
                        end
                    end
                end

                return n_diagnostics.ERROR, n_diagnostics.WARN, n_diagnostics.INFO, n_diagnostics.HINT
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
                        require('conf.ui').get_workspace_diff,
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
                    lualine_c = { require('conf.ui').winbar_symbol },
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
        end,
    },
    {
        'rcarriga/nvim-notify',
        event = 'VeryLazy',
        init = function()
            keymap('n', '<leader>fn', '<cmd>Telescope notify<cr>', opts)
        end,
        config = function()
            vim.notify = require 'notify'

            require('notify').setup {
                max_width = 45,
                max_height = 20,
            }
        end,
    },
    { 'echasnovski/mini.nvim' },
    {
        'folke/trouble.nvim',
        cmd = 'Trouble',
        config = function()
            require('trouble').setup {}
        end,
        init = function()
            local function opt(desc)
                return { silent = true, desc = desc, noremap = true }
            end

            keymap('n', '<leader>xw', '<cmd>Trouble diagnostics toggle<cr>', opt 'Workspace dianostics')
            keymap('n', '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', opt 'Document Diagnostics')
            keymap('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', opt 'Open loclist')
            keymap(
                'n',
                '<leader>xq',
                [[<cmd>lua require 'conf.ui'.reopen_qflist_by_trouble()<cr>]],
                opt 'Open quickfix'
            )
            keymap(
                'n',
                '<leader>xr',
                '<cmd>Trouble lsp toggle focus=false win.position=bottom<cr>',
                opt 'Lsp reference'
            )
        end,
    },
    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        config = function()
            local which_key = require 'which-key'
            which_key.setup {
                triggers = { '<leader>', '<localleader>', 'g', 'z', ']', '[', '`', '"', [[']], '@' },
            }

            which_key.register {
                ['<Leader>f'] = { name = '+find everything', mode = { 'n', 'v' } },
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
                ['<Leader>m'] = { name = '+misc', mode = { 'n', 'v' } },
                ['<Leader>mm'] = { name = '+markdown' },
                ['<Leader>md'] = { name = '+change directory' },
                [']<Space>'] = { name = '+Additional motions' },
                [']<Space>l'] = { name = '+latex motions' },
                ['[<Space>'] = { name = '+Additional motions' },
                ['[<Space>l'] = { name = '+latex motions' },
            }

            local keymap_for_repl = {}

            keymap_for_repl['<Leader><Space>'] = { name = '+localleader', buffer = 0 }
            keymap_for_repl['<Leader><Space>r'] = { name = '+REPL', buffer = 0 }
            keymap_for_repl['<Leader><Space>s'] = { name = '+send to REPL(motion)', buffer = 0, mode = { 'n', 'v' } }

            autocmd('FileType', {
                group = my_augroup,
                pattern = 'org',
                desc = 'add which key description for org',
                callback = function()
                    which_key.register {
                        ['<Leader><Space>'] = { name = '+localleader', buffer = 0 },
                        ['<Leader>oi'] = { name = '+org insert', buffer = 0 },
                        ['<Leader>ox'] = { name = '+org clock', buffer = 0 },
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
                pattern = { 'quarto', 'markdown', 'markdown.pandoc', 'rmd', 'python', 'r', 'sh', 'REPL' },
                group = my_augroup,
                desc = 'Add which key description for REPL',
                callback = function()
                    which_key.register(keymap_for_repl)
                end,
            })
        end,
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        event = 'LazyFile',
        config = function()
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
        end,
    },
    {
        'kyazdani42/nvim-web-devicons',
        config = function()
            return require('nvim-web-devicons').setup {}
        end,
    },
}
