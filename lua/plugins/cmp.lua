local function formatter(entry, vim_item)
    local icon, hl, is_default = require("mini.icons").get("lsp", vim_item.kind)
    local highlights_info = require("colorful-menu").cmp_highlights(entry)
    if is_default then
        icon = "󰞋"
        hl = "CmpItemKind" .. vim_item.kind
    end
    if highlights_info == nil then
        vim_item.abbr = entry:get_completion_item().label
    else
        vim_item.abbr_hl_group = highlights_info.highlights
        vim_item.abbr = highlights_info.text
    end
    vim_item.abbr = vim.trim(vim_item.abbr or "")
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
            "xzbdmw/colorful-menu.nvim",
            { 'echasnovski/mini.icons', version = false },
        },
        ft           = { "cpp", "hpp", "h", "go", "python" },
        event        = "InsertEnter",
        opts         = function()
            local cmp = require "cmp"
            return {
                preselect = cmp.PreselectMode.None,
                completion = {
                    keyword_length = 2,
                },
                window = {
                    completion = vim.tbl_extend("force", cmp.config.window.bordered(), {
                        winhighlight = "NormalFloat:None,FloatBorder:None,CursorLine:Visual,Search:None",
                    }),
                    documentation = vim.tbl_extend("force", cmp.config.window.bordered(), {
                        winhighlight = "NormalFloat:None,FloatBorder:None,CursorLine:Visual,Search:None",
                    }),
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
                    fields = { "kind", "abbr", "menu" },
                    format = formatter,
                },
            }
        end,
    },
}
