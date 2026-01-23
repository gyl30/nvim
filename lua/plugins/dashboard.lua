return {
    'goolord/alpha-nvim',
    config = function()
        local startify = require("alpha.themes.startify")
        startify.file_icons.enabled = false
        require 'alpha'.setup(
            startify.config
        )
    end
}
