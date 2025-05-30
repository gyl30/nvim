local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = { { import = "plugins" }, },
    change_detection = { notify = false, },
    pkg = {
        enabled = true,
    },
    rocks = {
        enabled = false,
    },
    transparent = true,
    styles = {
        floats = "transparent",
        sidebars = "transparent",
    },
    ui = {
        backdrop = 100,
    },
    install = {
        missing = true,
    },
    performance = {
        cache = {
            enabled = false,
        },
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
                "netrwPlugin",
            },
        },
    },
})
