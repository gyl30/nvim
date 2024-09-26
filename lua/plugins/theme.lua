return {
    'Mofiqul/dracula.nvim',
    config = function()
        require("dracula").setup({
              overrides = {
                  Normal = { bg = "NONE" },
              },
        })
    end
}
