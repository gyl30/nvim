local function formatter(entry, vim_item)
    local icon, hl, is_default = require("mini.icons").get("lsp", vim_item.kind)
    if is_default then
        icon = "󰞋"
        hl = "CmpItemKind" .. vim_item.kind
    end
    vim_item.kind = icon
    vim_item.kind_hl_group = hl
    vim_item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[Lsp]",
        nvim_lua = "[Lua]",
        path = "[Path]",
        codeium = "[Codeium]",
        supermaven = "[SuperMaven]",
    })[entry.source.name]
    return vim_item
end

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and
        vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

return {
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-nvim-lsp",
            { 'echasnovski/mini.nvim', version = false },
        },
        event = "InsertEnter",
        opts = function()
            local cmp = require "cmp"
            return {
                preselect = cmp.PreselectMode.None,
                completion = {
                    keyword_length = 2,
                },
                matching = {
                    disallow_fuzzy_matching = true,
                    disallow_fullfuzzy_matching = true,
                    disallow_partial_fuzzy_matching = false,
                    disallow_partial_matching = false,
                    disallow_prefix_unmatching = true,
                },
                mapping = {
                    ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                    ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() and has_words_before() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources {
                    { name = "nvim_lsp",   priority = 1000 },
                    { name = "supermaven", priority = 920 },
                    { name = "codeium",    priority = 900 },
                    { name = "nvim_lua",   priority = 800 },
                    { name = "buffer",     priority = 500 },
                    { name = "path",       priority = 250 },
                },
                formatting = {
                    mode = "symbol",
                    maxwidth = 80,
                    with_text = true,
                    format = formatter,
                },
            }
        end,
    },
}
