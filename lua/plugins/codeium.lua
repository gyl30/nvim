return {
    {
        "Exafunction/codeium.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "hrsh7th/nvim-cmp",
        },
        event = "BufEnter",
        config = function()
            require("codeium").setup({})
        end,
    },
    {
        "Exafunction/codeium.vim",
        event = "BufEnter",
        config = function()
            vim.keymap.set("i", "<C-g>", function() return vim.fn["codeium#Accept"]() end, { expr = true })
            vim.keymap.set("i", "<C-;>", function() return vim.fn["codeium#CycleCompletions"](1) end, { expr = true })
            vim.keymap.set("i", "<C-,>", function() return vim.fn["codeium#CycleCompletions"](-1) end, { expr = true })
            vim.keymap.set("i", "<C-x>", function() return vim.fn["codeium#Clear"]() end, { expr = true })
            vim.keymap.set("i", "<C-/>", function() return vim.fn["codeium#Complete"]() end, { expr = true })
        end,
    },
}
