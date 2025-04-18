return {
    'saghen/blink.cmp',
    version = '1.*',
    event = "InsertEnter",
    dependencies = {
        "moyiz/blink-emoji.nvim",
        "giuxtaposition/blink-cmp-copilot",
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
            accept = { auto_brackets = { enabled = true } },
            documentation = { auto_show = true, },
            list = {
                selection = { preselect = false, auto_insert = true }
            },
            trigger = { prefetch_on_insert = false },
            menu = {
                draw = {
                    align_to = 'label',
                    columns = { { 'label' }, { 'kind_icon' }, { 'source_name' } },
                    -- columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon' }, { 'source_name' } },
                    -- columns = {
                    --     { "kind_icon", "label",       "label_description", gap = 1 },
                    --     { "kind",      "source_name", gap = 1 },
                    -- },
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx) return ctx.kind_icon .. ctx.icon_gap end,
                            highlight = function(ctx) return { { group = ctx.kind_hl, priority = 20000 } } end,
                        },

                        label = {
                            width = { fill = true },
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
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
                show_documentation = true,
            }
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "copilot", "emoji" },
            providers = {
                copilot = {
                    name = "copilot",
                    module = "blink-cmp-copilot",
                    score_offset = 100,
                    async = true,
                },
                emoji = {
                    module = "blink-emoji",
                    name = "Emoji",
                    score_offset = 15,
                    opts = { insert = true },
                },
            },
        },
    },
    opts_extend = { "sources.default" }
}
