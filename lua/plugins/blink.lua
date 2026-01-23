return {
    'saghen/blink.cmp',
    version = '1.*',
    event = "InsertEnter",
    dependencies = {
        {
            'Exafunction/codeium.nvim',
            config = function()
                require("codeium").setup({
                    enable_cmp_source = false,
                    enable_chat = true,
                    quiet = true,
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
            default = { "lsp", "path", "snippets", "buffer", "emoji", "codeium" },
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
            },
        },
    },
    opts_extend = { "sources.default" }
}
