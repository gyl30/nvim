local colors = {
  yellow = '#ECBE7B',
  cyan = '#008080',
  darkblue = '#081633',
  green = '#98be65',
  orange = '#FF8800',
  violet = '#a9a1e1',
  magenta = '#c678dd',
  blue = '#51afef',
  red = '#ec5f67'
}

local opts = {
    options = {
        component_separators = { left = '', right = ''},
        section_separators = { left = '', right = ''},
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {
            {
                "filetype",
                icon_only = true,
                separator = "",
                padding = {
                left = 1, right = 0 }
            },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
            {
              
            }
        },
        lualine_x = {
            function()
                local msg = 'No Active Lsp'
                local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
                local clients = vim.lsp.get_active_clients()
                if next(clients) == nil then
                    return msg
                end
                for _, client in ipairs(clients) do
                    local filetypes = client.config.filetypes
                    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                        return client.name
                    end
                end
                return msg
            end,
            "require'lsp-status'.status_progress()",
            'fileformat',
            'encoding',
        },
        lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
            function()
                return " " .. os.date("%R")
            end,
        },
    },
    extensions = { "neo-tree", "lazy" },
}
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {'nvim-lua/lsp-status.nvim'},
    event = "VeryLazy",
    opts = opts,
}
