return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        'nvim-lua/plenary.nvim',
        "debugloop/telescope-undo.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
    },
  cmd = "Telescope",
  opts = function()
    local actions = require "telescope.actions"
    return {
      defaults = {
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        pickers = {
            lsp_references = {
                layout_strategy = "vertical",
                show_line = false,
                layout_config = {
                    prompt_position = "bottom",
                    width = 0.9,
                    height = 0.9,
                    preview_cutoff = 1,
                    mirror = false,
                },
            },
            live_grep = {
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
    }
  end,
    config = function(opts)
        require('telescope').setup{opts}
    end,
}
