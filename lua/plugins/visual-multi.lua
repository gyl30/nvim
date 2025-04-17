return {
    "mg979/vim-visual-multi",
    event = { "BufReadPost", "BufNewFile" },
    keys = { { '<C-n>', mode = { 'n', 'v' } } },
}
