return {
    "chrisgrieser/nvim-spider",
    lazy = true,
    keys = {
        {
            "e",
            "<cmd>lua require('spider').motion('e')<CR>",
            mode = { "n", "o", "x" },
        },
    },
}
