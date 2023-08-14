return {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    config = function()
        require("toggleterm").setup({
            size = 10,
            on_create = function()
                vim.opt.foldcolumn = "0"
                vim.opt.signcolumn = "no"
            end,
            shading_factor = 2,
            direction = "float",
            float_opts = {
                border = "curved",
                highlights = { border = "Normal", background = "Normal" },
            },
        })
        local opts = { noremap = true, silent = true }
    end,
    keys = {
        {
            '<leader>ft',
            mode = { 'n' },
            silent = true,
            '<cmd>ToggleTerm direction=float<cr>',
            desc = 'Floating Terminal'
        },
    },
}
