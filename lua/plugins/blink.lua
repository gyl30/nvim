return {
    'saghen/blink.cmp',
    version = '1.*',
    event = "InsertEnter",
    opts = {
        keymap = {
            ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<Tab>'] = { 'select_next', 'fallback' },
        },
        completion = {
            documentation = { auto_show = true, },
            list = {
                selection = { preselect = false, auto_insert = true }
            },
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
    },
    opts_extend = { "sources.default" }
}
