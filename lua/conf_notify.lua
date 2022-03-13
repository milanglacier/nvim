vim.notify = require("notify")

require('notify').setup({
    max_width = 45
})

require("telescope").load_extension("notify")
