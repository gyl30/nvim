return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        'nvim-lua/plenary.nvim',
        "debugloop/telescope-undo.nvim",
        "nvim-telescope/telescope-file-browser.nvim",
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
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        show_line = false,
        layout_config = {
            prompt_position = "bottom",
            width = 0.9,
            height = 0.9,
            preview_cutoff = 1,
            mirror = false,
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
    })
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('undo')
    require('telescope').load_extension("file_browser")
    end,
}
