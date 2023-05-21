local function getGreeting(name)
    local tableTime = os.date("*t")
    local datetime = os.date(" %Y-%m-%d   %H:%M:%S")
    local hour = tableTime.hour
    local greetingsTable = {
        [1] = "  Sleep well",
        [2] = "  Good morning",
        [3] = "  Good afternoon",
        [4] = "  Good evening",
        [5] = "󰖔  Good night",
    }
    local greetingIndex = 0
    if hour == 23 or hour < 7 then
        greetingIndex = 1
    elseif hour < 12 then
        greetingIndex = 2
    elseif hour >= 12 and hour < 18 then
        greetingIndex = 3
    elseif hour >= 18 and hour < 21 then
        greetingIndex = 4
    elseif hour >= 21 then
        greetingIndex = 5
    end
    return "\t" .. datetime .. "\t" .. greetingsTable[greetingIndex] .. ", " .. name
end
local config = function()
    local status, alpha = pcall(require, 'alpha')
    if not status then return end

    local dashboard = require 'alpha.themes.dashboard'

    -- local variables
    local winHeight = vim.fn.winheight(0)
    local buttonWidth = 40

    local banner = [[

        ██████   █████                   █████   █████  ███
       ░░██████ ░░███                   ░░███   ░░███  ░░░
        ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████
        ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███
        ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███
        ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███
        █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████
       ░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░

   ]]
    --local userName = "Gyl"
    --local greeting = getGreeting(userName)
    --dashboard.section.header.val = vim.split(banner .. "\n" .. greeting, "\n")
    dashboard.section.header.val = vim.split(banner, "\n")


    -- Menu
    dashboard.section.buttons.val = {
        dashboard.button('e', '󰈔 New file', ':ene <BAR> startinsert<CR>'),
        dashboard.button('r', '󱔗 Recent files', ':Telescope oldfiles <CR>'),
        dashboard.button('f', '󰱼 Find file', ':Telescope find_files<CR>'),
        dashboard.button('g', '󰺮 Find text', ':Telescope live_grep <CR>'),
        dashboard.button('u', ' Update plugins', ':Lazy update<CR>'),
        dashboard.button('c', ' Check health', ':checkhealth<CR>'),
        dashboard.button('q', ' Quit', ':qa<CR>'),
    }

    -- Colors
    -- defined in color theme (after/plugin/neosolarized.rc.lua)
    for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.width = buttonWidth
        button.opts.hl = 'AlphaButtons'
        button.opts.hl_shortcut = 'AlphaShortcut'
    end
    dashboard.section.header.opts.hl = 'AlphaHeader'
    dashboard.section.buttons.opts.hl = 'AlphaButtons'
    dashboard.section.footer.opts.hl = 'AlphaFooter'

    -- Align dashboard vertically
    local function getDashboardHeight()
        local bannerHeight = 0
        for _ in pairs(dashboard.section.header.val) do bannerHeight = bannerHeight + 1 end
        local buttonCount = 0
        for _ in pairs(dashboard.section.buttons.val) do buttonCount = buttonCount + 1 end
        local buttonsHeight = 2 * buttonCount
        local footerHeight = 1
        local dashboardHeight = bannerHeight + dashboard.opts.layout[3].val + buttonsHeight + footerHeight
        return dashboardHeight
    end

    if winHeight < getDashboardHeight() + 3 then
        -- Reduce dashboard size for small window heights
        dashboard.section.header.val = { 'Neovim' }
        table.remove(dashboard.section.buttons.val, 5)
        table.remove(dashboard.section.buttons.val, 5)
        table.remove(dashboard.section.buttons.val, 5)
        table.remove(dashboard.section.buttons.val, 5)
    end

    local topSpace = vim.fn.max { 0, vim.fn.floor((vim.fn.winheight(0) - getDashboardHeight()) / 2) }
    dashboard.opts.layout[1].val = topSpace
    if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
            pattern = "AlphaReady",
            callback = function()
                require("lazy").show()
            end,
        })
    end
    -- Setup
    alpha.setup(dashboard.config)

    vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            local version = "󰥱 v" .. vim.version().major .. "." .. vim.version().minor
            local plugins = "⚡Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
            local footer = version .. "\t" .. plugins .. "\n"
            dashboard.section.footer.val = footer
            pcall(vim.cmd.AlphaRedraw)
        end,
    })
end

return {
    "goolord/alpha-nvim",
    lazy = true,
    event = "VimEnter",
    config = config,
}
