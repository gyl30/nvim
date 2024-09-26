return {
    "f-person/git-blame.nvim",
    keys = {
        '<C-g>', mode = { 'n' }, silent = true, '<cmd>GitBlameToggle<cr>',
    },
    config = function()
        require('gitblame').setup {
            enabled = false,
            display_virtual_text = false,
        }
        vim.g.gitblame_display_virtual_text = 0
    end
}
