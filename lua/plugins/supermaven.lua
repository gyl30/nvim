return {
    "supermaven-inc/supermaven-nvim",

    ft = { "c", "cpp", "h", "hpp", "go", "lua", "sh", "python" },
    config = function()
        require("supermaven-nvim").setup({
            keymaps = {
                accept_suggestion = "<C-g>",
                clear_suggestion = "<C-]>",
            },
            color = {
                suggestion_color = "#00ffff",
                cterm = 244,
            }
        })
    end,
}
