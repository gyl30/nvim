return {
    "gyl30/translate",
    config = function()
        require("translate").setup({
            target = "zh",
        })

        vim.keymap.set("n", "<leader>t", function()
            require("translate").translateN()
        end, { desc = "Translate word under cursor" })

        vim.keymap.set("x", "<leader>t", function()
            require("translate").translateV()
        end, { desc = "Translate visual selection" })
    end,
}
