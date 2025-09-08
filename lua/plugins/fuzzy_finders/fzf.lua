local opts_desc = function(desc)
    return {
        noremap = true,
        desc = desc,
    }
end

local keymap = vim.api.nvim_set_keymap

local M = {
    {
        'ibhagwan/fzf-lua',
        cond = Milanglacier.fuzzy_finder == 'fzf',
        cmd = 'FzfLua',
        init = function()
            keymap('n', '<Leader>ff', '<cmd>FzfLua files<cr>', opts_desc 'Fzf Files')
            keymap(
                'n',
                '<Leader>fF',
                [[<cmd>FzfLua files cmd=rg\ --files\ --color\ never\ --hidden\ --no-ignore\ --iglob\ !.git<cr>]],
                opts_desc 'Fzf Files No ignore'
            )
            keymap('n', '<Leader>fG', '<cmd>FzfLua grep<cr>', opts_desc 'Fzf Grep')
            keymap('n', '<Leader>fg', '<cmd>FzfLua live_grep<cr>', opts_desc 'Fzf Live Grep')
            keymap('n', '<Leader>fb', '<cmd>FzfLua buffers<cr>', opts_desc 'Fzf buffers')
            keymap('n', '<Leader>fh', '<cmd>FzfLua helptags<cr>', opts_desc 'Fzf helptags')
            keymap('n', '<Leader>fk', '<cmd>FzfLua keymaps<cr>', opts_desc 'Fzf keymaps')

            keymap('n', '<Leader>fc', '<cmd>FzfLua commands<cr>', opts_desc 'Fzf commands')
            keymap('n', '<Leader>fC', '<cmd>FzfLua command_history<cr>', opts_desc 'Fzf commands history')

            keymap('n', '<leader>fs', '<cmd>FzfLua lsp_document_symbols<cr>', opts_desc 'lsp doc symbol')
            keymap(
                'n',
                '<leader>fw',
                '<cmd>FzfLua lsp_workspace_symbols cwd_only=true<cr>',
                opts_desc 'lsp workspace symbol'
            )
            keymap('n', '<leader>fr', '<cmd>FzfLua registers<cr>', opts_desc 'Fzf registers')
            keymap('n', '<leader>fj', '<cmd>FzfLua jumplist<cr>', opts_desc 'Fzf jumplist')
            keymap('n', '<leader>fo', '<cmd>FzfLua oldfiles<cr>', opts_desc 'Fzf oldfilels')
            keymap('n', '<leader>fT', '<cmd>FzfLua treesitter<cr>', opts_desc 'Fzf treesitter')
            keymap('n', '<leader>ft', '<cmd>FzfLua tags<cr>', opts_desc 'Fzf tags')
            keymap('n', '<leader>fm', '<cmd>FzfLua marks<cr>', opts_desc 'Fzf marks')

            keymap('n', '<leader>fe', '<cmd>FzfLua builtin<cr>', opts_desc 'Fzf extensions')

            keymap('n', '<leader>gml', '<cmd>FzfLua git_commits<cr>', opts_desc 'Git Log')
            keymap('n', '<leader>gmb', '<cmd>FzfLua git_bcommits<cr>', opts_desc 'Git Buffer Log')
            keymap('v', '<leader>gmb', '<cmd>FzfLua git_bcommits<cr>', opts_desc 'Git Hunk Log')
        end,
        config = function()
            local actions = require 'fzf-lua.actions'

            require('fzf-lua').setup {
                { 'border-fused' },

                winopts = {
                    height = 0.85,
                    width = 0.85,
                    row = 0.5,
                    col = 0.5,
                    preview = {
                        layout = 'vertical',
                        -- give more spaces for file previewer
                        vertical = 'up:60%',
                        scrollbar = false,
                    },
                },

                fzf_colors = true,
                fzf_opts = {
                    ['--no-scrollbar'] = true,
                    -- allow cycle from last item to first item
                    ['--cycle'] = true,
                    --  I usually use 4 for tab width. However I want to save
                    --  more spaces for one-liner
                    ['--tabstop'] = 2,
                },
                defaults = {
                    -- formatter = "path.filename_first",
                    formatter = 'path.dirname_first',
                    -- don't show the suggestin tip for keybindings. I know everything.
                    no_header_i = true,
                },

                keymap = {
                    builtin = {
                        ['<c-f>'] = 'preview-page-down',
                        ['<c-b>'] = 'preview-page-up',
                        ['<C-/>'] = 'toggle-help',
                    },
                    fzf = {
                        -- standard ctrl-k behavior as in bash
                        ['ctrl-k'] = 'kill-line',
                        -- vim-sneak style jump to an entry
                        ['ctrl-x'] = 'jump',
                        -- select/unselect current item and move to next
                        -- selected items can be send to qflist together
                        -- ['tab'] = 'toggle+down',
                        -- ['btab'] = 'toggle+up',
                    },
                },

                actions = {
                    files = {
                        -- use the default keybindings
                        true,
                        ['alt-i'] = actions.toggle_ignore,
                        ['alt-h'] = actions.toggle_hidden,
                        ['enter'] = actions.file_edit_or_qf,
                        -- send selected items to qf
                        ['alt-q'] = actions.file_edit_or_qf,
                        -- send all items to qf
                        ['ctrl-q'] = { fn = actions.file_edit_or_qf, prefix = 'select-all+' },
                    },
                },

                previews = {
                    syntax_limit_b = 1024 * 1000, -- 1MB
                },

                files = {
                    find_opts = [[-type f -not -path '*/\.git/*']],
                    rg_opts = [[--color=never --files --hidden --follow -g "!.git"]],
                    fd_opts = [[--color=never --type f --hidden --follow --exclude .git]],
                    cwd_prompt = false,
                    git_icons = false,
                    actions = {
                        ['ctrl-g'] = false,
                    },
                },

                grep = {
                    git_icons = false,
                    rg_glob = true,
                    actions = {
                        ['ctrl-g'] = false,
                    },
                },

                old_files = {
                    include_current_session = true,
                },

                registers = {
                    winopts = {
                        preview = {
                            vertical = 'up:0',
                        },
                    },
                },

                lsp = {
                    -- directly jump to the location when there is only one result
                    jump1 = true,
                    jump1_action = actions.file_edit,
                    -- for lsp references ignore current reference
                    ignore_current_line = true,
                },

                diagnostics = {
                    winopts = {
                        preview = {
                            vertical = 'up:50%',
                        },
                    },
                    fzf_opts = {
                        -- concat the source location and the diagnostics into
                        -- a single line.
                        ['--no-multi-line'] = true,
                    },
                },
            }

            require('fzf-lua').register_ui_select {
                winopts = {
                    height = 15,
                    width = 0.6,
                    preview = {
                        vertical = 'down:15,border-top',
                        hidden = 'hidden',
                    },
                },
            }
        end,
    },
}

return M
