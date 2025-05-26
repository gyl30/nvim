return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        styles = {
            input = {
                relative = "cursor",
                row = 1,
                col = 0,
                keys = {
                    i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i", expr = true },
                },
            },
        },
        bigfile = { enabled = true },
        dashboard = {
            sections = {
                { title = "Recent Files", padding = 1 },
                { section = "recent_files", limit = 8, padding = 1 },
                { title = "MRU ", file = vim.fn.fnamemodify(".", ":~"), padding = 1 },
                { section = "recent_files", cwd = true, limit = 8, padding = 1 },
                { section = "startup" },
            },
        },
    },
}
