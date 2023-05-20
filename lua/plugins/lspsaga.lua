local config = function()
    require("lspsaga").setup({})
end
return {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = config,
    dependencies = {
        { "nvim-tree/nvim-web-devicons" },
        { "nvim-treesitter/nvim-treesitter" }
    },
}
