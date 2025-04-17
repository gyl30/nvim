return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    ft = { "go", "cpp", "h", "hpp", "python" },
    lazy = true,
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            ensure_installed = { "c", "lua", "vim", "vimdoc", "cpp", "javascript", "html" },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}
