return {
    "f-person/git-blame.nvim",
    config = function()
        require('gitblame').setup {
            enabled = false,
            display_virtual_text = false,
        }
        vim.g.gitblame_display_virtual_text = 0
    end
}
