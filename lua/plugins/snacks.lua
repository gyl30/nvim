return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        dashboard = {
            sections = {
                { section = "terminal",     cmd = "fortune -s | cowsay",          hl = "header", padding = 0, indent = 8,  height = 15, },
                { title = "MRU",            padding = 0 },
                { section = "recent_files", limit = 8,                            padding = 1 },
                { title = "MRU ",           file = vim.fn.fnamemodify(".", ":~"), padding = 0 },
                { section = "recent_files", cwd = true,                           limit = 8,     padding = 1 },
                { section = "startup" },
            },
        },
        -- indent = { enabled = true },
        lazygit = { enabled = true },
    },
    keys = {
        { "<leader>z",  function() Snacks.zen() end,                   desc = "Toggle Zen Mode" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>cR", function() Snacks.rename.rename_file() end,    desc = "Rename File" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end,      desc = "Lazygit Current File History" },
        { "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
        { "<leader>gl", function() Snacks.lazygit.log() end,           desc = "Lazygit Log (cwd)" },
        { "<leader>un", function() Snacks.notifier.hide() end,         desc = "Dismiss All Notifications" },
    },
}
