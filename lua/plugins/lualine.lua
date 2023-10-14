local uv = vim.version().minor >= 10 and vim.uv or vim.loop
local iswin = uv.os_uname().sysname:match('Windows')
local path_sep = iswin and '\\' or '/'


local function lsp_icon()
    return require("lsp-progress").progress({
        format = function(messages)
            if #messages > 0 then
                return ""
            end
            local msg = 'No Active Lsp'
            local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
                return msg
            end
            local names = {}
            for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                local name = string.find(client.name, '_') ~= nil and string.upper(client.name) or client.name
                name = string.find(name, '-') ~= nil and string.upper(name) or name
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 and names[name] == nil then
                    names[name] = true
                end
            end
            local clinet_name = ""
            for name, _ in pairs(names) do
                clinet_name = clinet_name .. ' ' .. name
            end
            return clinet_name
        end,
    })
end

local function lsp_message()
    return require("lsp-progress").progress({
        format = function(messages)
            return #messages > 0 and table.concat(messages, " ") or ""
        end,
    })
end

local client_format = function(client_name, spinner, series_messages)
    client_name = string.find(client_name, '_') ~= nil and string.upper(client_name) or client_name
    return #series_messages > 0
        and (" " .. client_name .. " " .. spinner .. " " .. table.concat(
            series_messages,
            ", "
        ))
        or nil
end

local opts = {
    options = {
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha", "lazy" } },
    },
    sections = {
        lualine_a = { "mode" },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
            {
                "filetype",
                icon_only = true,
                separator = "",
                padding = {
                    left = 1, right = 0 }
            },
            { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
        },
        lualine_x = {
            lsp_icon,
            lsp_message,
            'fileformat',
            'encoding',
            {
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
            },
        },
        lualine_y = {
            { "progress", separator = " ",                  padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
        },
        lualine_z = {
            function()
                return " " .. os.date("%R")
            end,
        },
    },
}

return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        {
            'linrongbin16/lsp-progress.nvim',
            config = function()
                require('lsp-progress').setup({
                    client_format = client_format,
                })
            end
        },
    },
    event = "VeryLazy",
    opts = opts,
}
