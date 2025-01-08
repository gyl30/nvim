return {
    {

        'Mofiqul/dracula.nvim',
        lazy = false,
        priority = 1000,
        opts = {},
    },
    {
        'ray-x/aurora',
        init = function()
            vim.g.aurora_italic = 1
            vim.g.aurora_transparent = 1
            vim.g.aurora_bold = 1
        end,
    }
}
