return {
        "glepnir/lspsaga.nvim",
        event = "LspAttach",
        enabled = false,
        config = function() require("lspsaga").setup {} end,
        dependencies = {
            { "nvim-tree/nvim-web-devicons" },
            { "nvim-treesitter/nvim-treesitter" },
        },
    }