return {
    "rcarriga/nvim-notify",
    event = "VimEnter",
    config = function()
        vim.notify = require("notify")
        vim.notify.setup({
            background_colour = "#000000"
        })
    end
}
