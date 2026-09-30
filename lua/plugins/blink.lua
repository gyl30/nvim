return {
    'saghen/blink.cmp',
    version = '1.*',
    event = "InsertEnter",
    dependencies = {
        {
            'Exafunction/codeium.nvim',
            dependencies = {
                'nvim-lua/plenary.nvim',
            },
            config = function()
                require("codeium").setup({
                    enable_cmp_source = false,
                    enable_chat = true,
                    quiet = true,
                })
            end
        },
        {
            "fang2hou/blink-copilot",
        },
        "moyiz/blink-emoji.nvim",
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
                nerd_font_variant = "normal",
            },
            documentation = { auto_show = true, },
            list = {
                selection = { preselect = false, }
            },
            trigger = { prefetch_on_insert = false },
            menu = {
                draw = {
                    columns = {
                        { "kind_icon", "label",       "label_description", gap = 1 },
                        { "kind",      "source_name", gap = 1 },
                    },
                }
            }
        },
        fuzzy = { implementation = "lua" },
        signature = {
            enabled = true,
            window = {
                border = 'single',
                show_documentation = false,
            }
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer", "emoji", "codeium", "copilot", },
            providers = {
                lsp = {
                    fallbacks = {},
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
                copilot = {
                    name = "copilot",
                    module = "blink-copilot",
                    async = true,
                    score_offset = 100,

                    opts = {
                        max_completions = 3,
                        max_attempts = 4,
                        debounce = 300,
                        auto_refresh = {
                            backward = false,
                            forward = true,
                        },
                    },
                },
            },
        },
    },
}
