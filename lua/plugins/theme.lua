return {
    {
        'Mofiqul/dracula.nvim',
        config = function()
            require("dracula").setup({
                overrides = function(colors)
                    return {
                        Normal = { bg = "NONE" }, -- set NonText fg to white of theme
                    }
                end,
            })
        end

    },
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            on_highlights = function(hl, c)
                hl.Normal = { bg = "NONE" }
                hl.TelescopePromptNormal = {
                    bg = '#2d3149',
                }
                hl.TelescopePromptBorder = {
                    bg = '#2d3149',
                }
                hl.TelescopePromptTitle = {
                    fg = '#2d3149',
                    bg = '#2d3149',
                }
                hl.TelescopePreviewTitle = {
                    fg = '#1F2335',
                    bg = '#1F2335',
                }
                hl.TelescopeResultsTitle = {
                    fg = '#1F2335',
                    bg = '#1F2335',
                }
            end
        })
    end

}
