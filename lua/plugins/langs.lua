local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

return {
    {
        'vim-pandoc/vim-pandoc-syntax',
        event = 'VeryLazy',
        dependencies = {
            { 'vim-pandoc/vim-rmarkdown', branch = 'official-filetype' },
            { 'quarto-dev/quarto-vim' },
        },
        init = function()
            vim.filetype.add {
                extension = {
                    md = 'markdown.pandoc',
                },
            }

            vim.g.r_indent_align_args = 0
            vim.g.r_indent_ess_comments = 0
            vim.g.r_indent_ess_compatible = 0

            vim.g['pandoc#syntax#codeblocks#embeds#langs'] = { 'python', 'R=r', 'r', 'bash=sh', 'json' }
        end,
    },
    {
        'lervag/vimtex',
        ft = 'tex',
        init = function()
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
        end,
    },
    {
        'jmbuhr/otter.nvim',
        ft = 'quarto',
        config = function()
            require('otter').activate({ 'r', 'python' }, true)
        end,
    },
}
