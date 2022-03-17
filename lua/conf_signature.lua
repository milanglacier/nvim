local M = {}


function M.on_attach(bufnr)

    require "lsp_signature".on_attach({
        bind = true, -- This is mandatory, otherwise border config won't get registered.
        handler_opts = {
            border = "rounded"
        },
        toggle_key = "<A-x>"
    }, bufnr)
end

return M
