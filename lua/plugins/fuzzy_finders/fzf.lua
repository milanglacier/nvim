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
            keymap('n', '<Leader>fe', '<CMD>FzfLua builtin<CR>', opts_desc 'Fzf Extensions')
            keymap('n', '<Leader>ff', '<CMD>FzfLua files<CR>', opts_desc 'Fzf Files')
            keymap('n', '<Leader>fo', '<CMD>FzfLua oldfiles<CR>', opts_desc 'Fzf Recent Files')
            keymap(
                'n',
                '<Leader>fF',
                [[<CMD>FzfLua files cmd=rg\ --files\ --color\ never\ --hidden\ --no-ignore\ --iglob\ !.git<CR>]],
                opts_desc 'Fzf Files No ignore'
            )
        end,
        config = function()
            local actions = require 'fzf-lua.actions'

            require('fzf-lua').setup {
                'default-title',

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
                    jump_to_single_result = true,
                    -- open a new tab when there is only one result
                    jump_to_single_result_action = actions.file_tabedit,
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
