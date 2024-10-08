return {
    {
        "Exafunction/codeium.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
             "iguanacucumber/magazine.nvim",
        },
        event        = "VeryLazy",
        config       = function()
            require("codeium").setup({})
        end,
        ft           = { "cpp", "hpp", "h", "go", "python" }
    },
}
