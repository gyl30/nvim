local luasnip = function(opts)
    require("luasnip").config.set_config(opts)
    require("luasnip.loaders.from_vscode").lazy_load()
    vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
            if
                require("luasnip").session.current_nodes[vim.api.nvim_get_current_buf()]
                and not require("luasnip").session.jump_active
            then
                require("luasnip").unlink_current()
            end
        end,
    })
end
local keys = {
    {
        "<tab>",
        function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
    },
    { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
    { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
}
return {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets", },
    keys = keys,
    opts = { history = true, updateevents = "TextChanged,TextChangedI" },
    config = function(_, opts)
        luasnip(opts)
    end,
    event = "InsertCharPre",
}
