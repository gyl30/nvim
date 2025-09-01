local function blink_highlight(ctx)
    local hl = "BlinkCmpKind" .. ctx.kind
        or require("blink.cmp.completion.windows.render.tailwind").get_hl(ctx)
    if vim.tbl_contains({ "Path" }, ctx.source_name) then
        local dev_icon, dev_hl = require("nvim-web-devicons").get_icon(ctx.label)
        if dev_icon then hl = dev_hl end
    end
    return hl
end
return {
    'saghen/blink.cmp',
    version = '1.*',
    event = "InsertEnter",
    dependencies = {
        {
            'Exafunction/codeium.nvim',
            config = function()
                require("codeium").setup({
                })
            end
        },
        {
            "onsails/lspkind.nvim",
            opts = {
                symbol_map = {
                    spell = "󰓆",
                    cmdline = "",
                    markdown = "",
                },
            },
        },
        'saghen/blink.compat',
        "moyiz/blink-emoji.nvim",
        {
            "supermaven-inc/supermaven-nvim",
            opts = {
                disable_inline_completion = true, -- disables inline completion for use with cmp
                disable_keymaps = true            -- disables built in keymaps for more manual control
            }
        },
        {
            "huijiro/blink-cmp-supermaven"
        },
    },
    opts = {
        keymap = {
            ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<Tab>'] = { 'select_next', 'fallback' },
            ['<C-p>'] = { 'select_prev', 'fallback' },
            ['<C-n>'] = { 'select_next', 'fallback' },
            ['<CR>'] = { 'accept', 'fallback' },
        },
        completion = {
            appearance = {
                use_nvim_cmp_as_default = false,
                nerd_font_variant = "normal",
            },
            accept = { auto_brackets = { enabled = true } },
            documentation = { auto_show = true, },
            list = {
                selection = { preselect = false, auto_insert = true }
            },
            trigger = { prefetch_on_insert = false },
            menu = {
                draw = {
                    align_to = 'label',
                    -- columns = { { 'label' }, { 'kind_icon' }, { 'source_name' } },
                    -- columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon' }, { 'source_name' } },
                    columns = {
                        { "kind_icon", "label",       "label_description", gap = 1 },
                        { "kind",      "source_name", gap = 1 },
                    },
                    treesitter = { 'lsp' },
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx)
                                local lspkind = require("lspkind")
                                local icon = ctx.kind_icon

                                if vim.tbl_contains({ "Path" }, ctx.source_name) then
                                    local dev_icon, _ =
                                        require("nvim-web-devicons").get_icon(
                                            ctx.label
                                        )
                                    if dev_icon then icon = dev_icon end
                                else
                                    if
                                        vim.tbl_contains({
                                            "spell",
                                            "cmdline",
                                            "markdown",
                                            "Dict",
                                        }, ctx.source_name)
                                    then
                                        icon = lspkind.symbolic(
                                            ctx.source_name,
                                            { mode = "symbol" }
                                        )
                                    else
                                        icon = lspkind.symbolic(ctx.kind, {
                                            mode = "symbol",
                                        })
                                    end
                                end

                                return icon .. ctx.icon_gap
                            end,
                            highlight = function(ctx) return blink_highlight(ctx) end,
                        },
                        kind = {
                            highlight = function(ctx) return blink_highlight(ctx) end,
                        },
                    },
                }
            }
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        signature = {
            enabled = true,
            window = {
                border = 'single',
                show_documentation = false,
            }
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "emoji", "supermaven", "codeium" },
            providers = {
                lsp = {
                    fallbacks = {},
                },
                supermaven = {
                    name = 'supermaven',
                    module = "blink-cmp-supermaven",
                    async = true
                },
                codeium = { name = 'Codeium', module = 'codeium.blink', async = true },
                emoji = {
                    module = "blink-emoji",
                    name = "Emoji",
                    score_offset = 15,
                    opts = { insert = true },
                    should_show_items = function()
                        return vim.tbl_contains(
                            { "gitcommit", "markdown" },
                            vim.o.filetype
                        )
                    end,
                },
            },
        },
    },
    opts_extend = { "sources.default" }
}
