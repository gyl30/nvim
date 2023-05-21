local config = function()
    require("catppuccin").setup({
        flavour = "mocha", -- latte, frappe, macchiato, mocha
        --background = {
        --light = "latte",
        --dark = "mocha",
        --},
        transparent_background = true,
        show_end_of_buffer = false, -- show the '~' characters after the end of buffers
        term_colors = false,
        dim_inactive = {
            enabled = false,
            shade = "dark",
            percentage = 0.15,
        },
        no_italic = false, -- Force no italic
        no_bold = false,   -- Force no bold
        semantic_tokens = true,
        symbols_outline = true,
        no_underline = false, -- Force no underline
        styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            loops = {},
            functions = {},
            keywords = {},
            strings = {},
            variables = {},
            numbers = {},
            booleans = {},
            properties = {},
            types = {},
            operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
            lsp_saga = true,
            markdown = true,
            cmp = true,
            gitsigns = true,
            telescope = true,
            native_lsp = {
                enabled = true,
                virtual_text = {
                    errors = { "italic" },
                    hints = { "italic" },
                    warnings = { "italic" },
                    information = { "italic" },
                },
                underlines = {
                    errors = { "underline" },
                    hints = { "underline" },
                    warnings = { "underline" },
                    information = { "underline" },
                },
            },
            navic = {
                enabled = true,
                custom_bg = "NONE",
            },
        },
    })
end
return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        config = config,
    },
    { "dracula/vim", name = "dracula" }
}
