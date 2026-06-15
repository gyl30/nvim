return {
    "gyl30/translate",
    cmd = {
        "Translate",
        "TranslateV",
    },
    opts = {
        target = "zh",
        source = nil,
        use_tsocks = "auto",
        timeout = 5000,
    },
    init = function()
        vim.keymap.set("n", "<leader>t", "<cmd>Translate<cr>", {
            silent = true,
            desc = "Translate word under cursor",
        })

        vim.keymap.set("x", "<leader>t", ":<C-u>TranslateV<cr>", {
            silent = true,
            desc = "Translate visual selection",
        })
    end,
}
