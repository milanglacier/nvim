local M = {}


function M.on_attach(bufnr)

    require "lsp_signature".on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
            border = "double"
        },
        toggle_key = "<A-x>",
        floating_window_off_x = 15, -- adjust float windows x position.
        floating_window_off_y = 15,
        -- hint_enable = true,
        -- hint_prefix = "",
        -- doc_lines = 5,
        time_interval = 100,

    }, bufnr)
end

return M
