return {
    'aaronik/treewalker.nvim',
    opts = {
        highlight = true,
        highlight_duration = 250,
        highlight_group = 'CursorLine',
    },
    ft = { "c", "cpp", "hpp", "go", "python", "lua" },
    keys = {
        { "<C-h>", "<cmd>Treewalker Left<cr>",  desc = "Treewalker left" },
        { "<C-l>", "<cmd>Treewalker Right<cr>", desc = "Treewalker right" },
        { "<C-j>", "<cmd>Treewalker Down<cr>",  desc = "Treewalker down" },
        { "<C-k>", "<cmd>Treewalker Up<cr>",    desc = "Treewalker up" },
    },
}
