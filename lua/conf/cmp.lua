local M = {}

-- we want to change the sources at runtime to disable/enable codeium.nvim

M.sources = {
    global = {
        {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            {
                name = 'tags',
                option = {
                    exact_match = true,
                    current_buffer_only = true,
                },
            },
        },
        {
            { name = 'buffer' },
            { name = 'path' },
        },
    },
    quarto = {
        {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'tags' },
        },
        {
            { name = 'buffer' },
            { name = 'path' },
        },
    },
    r_rmd = {
        {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
            { name = 'tags' },
        },
        {
            -- { name = 'cmp_nvim_r' },
            { name = 'buffer' },
            { name = 'path' },
        },
    },
}

return M
