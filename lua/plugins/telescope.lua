return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        'nvim-lua/plenary.nvim',
        "debugloop/telescope-undo.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
        'GustavoKatel/telescope-asynctasks.nvim',
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
            cond = function()
                return vim.fn.executable("make") == 1
            end,
        },
    },
    cmd = "Telescope",
    config = function()
        local actions = require "telescope.actions"
        require('telescope').setup({
            defaults = {
                prompt_prefix = "❯ ",
                selection_caret = "❯ ",
                winblend = 0,
                border = {},
                dynamic_preview_title = true,
                path_display = { 'absolute' },
                disable_coordinates = true,
                initial_mode = "normal",
                sorting_strategy = "ascending",
                layout_strategy = "vertical",
                borderchars = nil,
                color_devicons = true,
                set_env = { ["COLORTERM"] = "truecolor" },
                layout_config = {
                    prompt_position = "bottom",
                    width = 0.9,
                    height = 0.9,
                    preview_cutoff = 1,
                    vertical = {
                        mirror = false,
                    },
                },
                mappings = {
                    i = {
                        ["<C-n>"] = actions.cycle_history_next,
                        ["<C-p>"] = actions.cycle_history_prev,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-k>"] = actions.move_selection_previous,
                    },
                    n = { q = actions.close },
                },
            },
            pickers = {
                lsp_references = {
                    layout_strategy = "vertical",
                    show_line = false,
                    trim_text = true,
                    include_declaration = false,
                    layout_config = {
                        prompt_position = "bottom",
                        width = 0.9,
                        height = 0.9,
                        preview_cutoff = 1,
                        mirror = false,
                    },
                },
                live_grep = {
                    ignore_filename = true,
                    layout_strategy = "vertical",
                    layout_config = {
                        prompt_position = "bottom",
                        width = 0.9,
                        height = 0.9,
                        preview_cutoff = 1,
                        mirror = false,
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = 'smart_case',       -- or "ignore_case" or "respect_case"
                },
            },
        })
        require('telescope').load_extension('fzf')
        require('telescope').load_extension('undo')
        require('telescope').load_extension("file_browser")
        require('telescope').load_extension("asynctasks")
    end,
}
