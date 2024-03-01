return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("fzf-lua").setup({
            -- winopts = {
            --     preview = {
            --         -- layout = "horizontal"
            --         layout = "vertical"
            --     }
            -- }
        })

        vim.keymap.set({ "n" }, "<C-x><C-f>",
            function()
                require("fzf-lua").lsp_finder({
                    winopts = { preview = { layout = "vertical" } }
                })
            end, { silent = true, desc = "Fuzzy lsp finder" })
    end
}
