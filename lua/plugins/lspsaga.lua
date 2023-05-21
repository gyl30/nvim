local config = function()
    require("lspsaga").setup({
        ui = {
            kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
        },
    })
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
