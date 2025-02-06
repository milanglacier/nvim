local autocmd = vim.api.nvim_create_autocmd
local my_augroup = require('conf.builtin_extend').my_augroup

return {
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
                    local bufmap = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, {
                            buffer = true,
                            noremap = false,
                            silent = true,
                            desc = desc,
                        })
                    end

                    bufmap('n', '<LocalLeader>lt', '<Plug>(vimtex-toc-toggle)')
                    bufmap('n', '<LocalLeader>ll', '<Plug>(vimtex-compile)')
                    bufmap('n', '<LocalLeader>lc', '<Plug>(vimtex-clean)')
                    bufmap('n', '<LocalLeader>lv', '<Plug>(vimtex-view)')
                    bufmap('n', '<LocalLeader>lk', '<Plug>(vimtex-stop)')
                    bufmap('n', '<LocalLeader>lm', '<Plug>(vimtex-toggle-main)')
                    bufmap('n', '<LocalLeader>la', '<Plug>(vimtex-context-menu)')
                    bufmap('n', '<LocalLeader>lo', '<Plug>(vimtex-compile-output)')
                    bufmap('n', '<LocalLeader>ss', '<Plug>(vimtex-env-surround-line)')
                    bufmap('n', '<LocalLeader>s', '<Plug>(vimtex-env-surround-operator)')
                    bufmap('x', '<LocalLeader>s', '<Plug>(vimtex-env-surround-visual)')

                    bufmap('n', 'dse', '<plug>(vimtex-env-delete)')
                    bufmap('n', 'dsc', '<plug>(vimtex-cmd-delete)')
                    bufmap('n', 'ds$', '<plug>(vimtex-env-delete-math)')
                    bufmap('n', 'dsd', '<plug>(vimtex-delim-delete)')
                    bufmap('n', 'cse', '<plug>(vimtex-env-change)')
                    bufmap('n', 'csc', '<plug>(vimtex-cmd-change)')
                    bufmap('n', 'cs$', '<plug>(vimtex-env-change-math)')
                    bufmap('n', 'csd', '<plug>(vimtex-delim-change-math)')
                    bufmap({ 'n', 'x' }, '<LocalLeader>tf', '<plug>(vimtex-cmd-toggle-frac)')
                    bufmap('n', '<LocalLeader>tc*', '<plug>(vimtex-cmd-toggle-star)')
                    bufmap('n', '<LocalLeader>te*', '<plug>(vimtex-env-toggle-star)')
                    bufmap('n', '<LocalLeader>t$', '<plug>(vimtex-env-toggle-math)')
                    bufmap({ 'n', 'x' }, '<LocalLeader>td', '<plug>(vimtex-delim-toggle-modifier)')
                    bufmap({ 'n', 'x' }, '<LocalLeader>tD', '<plug>(vimtex-delim-toggle-modifier-reverse)')
                    bufmap({ 'n', 'x' }, '<LocalLeader>c', '<plug>(vimtex-cmd-create)')

                    bufmap({ 'x', 'o' }, 'ac', '<plug>(vimtex-ac)', 'vimtex texobj around command')
                    bufmap({ 'x', 'o' }, 'ic', '<plug>(vimtex-ic)', 'vimtex texobj in command')
                    bufmap({ 'x', 'o' }, 'ad', '<plug>(vimtex-ad)', 'vimtex texobj around delim')
                    bufmap({ 'x', 'o' }, 'id', '<plug>(vimtex-id)', 'vimtex texobj in delim')
                    bufmap({ 'x', 'o' }, 'ae', '<plug>(vimtex-ae)', 'vimtex texobj around env')
                    bufmap({ 'x', 'o' }, 'ie', '<plug>(vimtex-ie)', 'vimtex texobj in env')
                    bufmap({ 'x', 'o' }, 'a$', '<plug>(vimtex-a$)', 'vimtex texobj around math')
                    bufmap({ 'x', 'o' }, 'i$', '<plug>(vimtex-i$)', 'vimtex texobj in math')
                    bufmap({ 'x', 'o' }, 'as', '<plug>(vimtex-aP)', 'vimtex texobj around section')
                    bufmap({ 'x', 'o' }, 'is', '<plug>(vimtex-iP)', 'vimtex texobj in section')
                    bufmap({ 'x', 'o' }, 'al', '<plug>(vimtex-am)', 'vimtex texobj around item')
                    bufmap({ 'x', 'o' }, 'il', '<plug>(vimtex-im)', 'vimtex texobj in item')

                    bufmap({ 'n', 'x', 'o' }, '%', '<plug>(vim-tex-%)')

                    bufmap({ 'n', 'x', 'o' }, ']]', '<plug>(vimtex-]])', 'vimtex motion next start of section')
                    bufmap({ 'n', 'x', 'o' }, '][', '<plug>(vimtex-][)', 'vimtex motion next end of section')
                    bufmap({ 'n', 'x', 'o' }, '[]', '<plug>(vimtex-[])', 'vimtex motion prev start of section')
                    bufmap({ 'n', 'x', 'o' }, '[[', '<plug>(vimtex-[[)', 'vimtex motion prev end of section')
                    bufmap({ 'n', 'x', 'o' }, ']e', '<plug>(vimtex-]m)', 'vimtex motion next start of env')
                    bufmap({ 'n', 'x', 'o' }, ']E', '<plug>(vimtex-]M)', 'vimtex motion next end of env')
                    bufmap({ 'n', 'x', 'o' }, '[e', '<plug>(vimtex-[m)', 'vimtex motion prev start of env')
                    bufmap({ 'n', 'x', 'o' }, '[E', '<plug>(vimtex-[M)', 'vimtex motion prev end of env')
                    bufmap({ 'n', 'x', 'o' }, ']m', '<plug>(vimtex-]n)', 'vimtex motion next start of math')
                    bufmap({ 'n', 'x', 'o' }, ']M', '<plug>(vimtex-]N)', 'vimtex motion next end of math')
                    bufmap({ 'n', 'x', 'o' }, '[m', '<plug>(vimtex-[n)', 'vimtex motion prev start of math')
                    bufmap({ 'n', 'x', 'o' }, '[M', '<plug>(vimtex-[N)', 'vimtex motion prev end of math')
                    bufmap({ 'n', 'x', 'o' }, ']f', '<plug>(vimtex-]r)', 'vimtex motion next start of frame')
                    bufmap({ 'n', 'x', 'o' }, ']F', '<plug>(vimtex-]R)', 'vimtex motion next end of frame')
                    bufmap({ 'n', 'x', 'o' }, '[f', '<plug>(vimtex-[r)', 'vimtex motion prev start of frame')
                    bufmap({ 'n', 'x', 'o' }, '[F', '<plug>(vimtex-[R)', 'vimtex motion prev end of frame')

                    bufmap('n', 'K', '<plug>(vimtex-doc-package)')
                end,
            })
        end,
    },
    {
        'jmbuhr/otter.nvim',
        ft = 'quarto',
        config = function()
            autocmd('FileType', {
                pattern = 'quarto',
                callback = function()
                    require('otter').activate({ 'r', 'python' }, true)
                end,
            })
        end,
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'rmd', 'quarto' },
        config = function()
            require('render-markdown').setup {
                file_types = { 'markdown', 'rmd', 'quarto' },
                code = {
                    sign = false,
                },
                heading = {
                    sign = false,
                    icons = { '󰬺 ', '󰬻 ', '󰬼 ', '󰬽 ', '󰬾 ', '󰬿 ' },
                },
            }
        end,
    },
}
