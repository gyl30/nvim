local config = function()
local navic = require("nvim-navic")
 require("lualine").setup({
        extensions = {},
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" ,
             {
              function()
                  return navic.get_location()
              end,
              cond = function()
                  return navic.is_available()
              end
            },
          },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
        },
        options = {
            --globalstatus = true,
            always_divide_middle = true,
            component_separators = {
                left = "|",
                right = "|",
            },
            disabled_filetypes = {},
            icons_enabled = false,
            section_separators = {
                left = "",
                right = "",
            },
            theme = theme,
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "diff", "diagnostics" },
            --lualine_b = { 'branch', 'diff', 'diagnostics' },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
        },
        tabline = {},
    })
end
return {
       "nvim-lualine/lualine.nvim", event = "ColorScheme", config = config ,
}
