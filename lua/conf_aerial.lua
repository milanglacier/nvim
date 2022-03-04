
-- Call the setup function to change the default behavior
require("aerial").setup({
    -- Priority list of preferred backends for aerial.
    -- This can be a filetype map (see :help aerial-filetype-map)
    backends = {  "treesitter", "lsp", "markdown" },

    -- Enum: persist, close, auto, global
    --   persist - aerial window will stay open until closed
    --   close   - aerial window will close when original file is no longer visible
    --   auto    - aerial window will stay open as long as there is a visible
    --             buffer to attach to
    --   global  - same as 'persist', and will always show symbols for the current buffer
    close_behavior = "close",

    -- Set to false to remove the default keybindings for the aerial buffer
    default_bindings = true,

    -- A list of all symbols to display. Set to false to display all symbols.
    -- This can be a filetype map (see :help aerial-filetype-map)
    -- To see all available values, see :help SymbolKind
    filter_kind = false,


    -- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
    -- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
    -- default collapsed icon. The default icon set is determined by the
    -- "nerd_font" option below.
    -- If you have lspkind-nvim installed, aerial will use it for icons.
    icons = {},

    -- Call this function when aerial attaches to a buffer.
    -- Useful for setting keymaps. Takes a single `bufnr` argument.
    on_attach = function(bufnr)
        -- Toggle the aerial window with <leader>a
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>so', '<cmd>AerialToggle!<CR>', {})
        -- Jump forwards/backwards with '{' and '}'
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '{', '<cmd>AerialPrev<CR>', {})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '}', '<cmd>AerialNext<CR>', {})
        -- Jump up the tree with '[[' or ']]'
        vim.api.nvim_buf_set_keymap(bufnr, 'n', '[[', '<cmd>AerialPrevUp<CR>', {})
        vim.api.nvim_buf_set_keymap(bufnr, 'n', ']]', '<cmd>AerialNextUp<CR>', {})
    end,

})
