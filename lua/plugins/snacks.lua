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
                -- { section = "terminal",     cmd = "fortune -s | cowsay",          hl = "header", padding = 0, indent = 8, height = 15, },
                { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                -- { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
                { section = "startup" },
            },
        },
    },
}
