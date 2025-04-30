return {
    "ibhagwan/fzf-lua",
    keys = {
        { "gr",         function() require("fzf-lua").lsp_references({ jump1 = true, ignore_current_line = true}) end, desc = "References" },
        { "gd",         function() require("fzf-lua").lsp_definitions() end,                                                                        desc = "Definitions" },
        { "gi",         function() require("fzf-lua").lsp_implementations() end,                                                                    desc = "Implementations" },
        { "<leader>qf", function() require("fzf-lua").lsp_code_actions() end,                                                                       desc = "Code Actions" },
        { "<leader>d",  function() require("fzf-lua").lsp_document_diagnostics() end,                                                               desc = "Document Diagnostics" },
    },
    config = function()
        require("fzf-lua").setup({
            defaults = { file_icons = "mini" },
            fzf_opts = {
                ['--info']    = false,
                ['--no-info'] = '',
                ['--layout']  = 'reverse-list',
                ['--border']  = 'none',
            },
            keymap   = {
                builtin = {
                    ['<C-a>'] = 'toggle-fullscreen',
                    ['<C-i>'] = 'toggle-preview',
                },
            },
            winopts  = {
                height = 0.8,
                width = 0.9,
                preview = {
                    default = "bat",
                    scrollbar = false,
                    layout = 'vertical',
                    vertical = 'up:50%,border-bottom',
                },
            },
        })
        require("fzf-lua").register_ui_select()
    end
}
