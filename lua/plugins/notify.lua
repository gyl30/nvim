return {
    "rcarriga/nvim-notify",
    event = "VimEnter",
    config = function()
        require('notify').setup({
            background_colour = "#000000"
        })
    end
}
