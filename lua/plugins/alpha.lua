return {
        "goolord/alpha-nvim",
        lazy = true,
        event = "VimEnter",
        config = function()
            local alpha = require("alpha")
            local startify = require("alpha.themes.startify")
            alpha.setup(startify.config)
        end,
    }