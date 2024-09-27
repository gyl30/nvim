return {
    'Mofiqul/dracula.nvim',
    config = function()
        require("dracula").setup({
            overrides = function(colors)
                return {
                    Normal = { bg = "NONE" },
                }
            end,
        })
    end
}
