return {
    "echasnovski/mini.indentscope",
    event = { "BufReadPre", "BufNewFile" },
    opts = { symbol = "╎", options = { try_as_border = true } },
    init = function()
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "aerial",
                "alpha",
                "dashboard",
                "fzf",
                "help",
                "neo-tree",
                "lazy",
                "lspinfo",
                "mason",
                "notify",
                "null-ls-info",
                "starter",
                "toggleterm",
                'floaterm',
                "Trouble",
                "undotree",
            },
            callback = function() vim.b.miniindentscope_disable = true end,
        })
    end,
}
