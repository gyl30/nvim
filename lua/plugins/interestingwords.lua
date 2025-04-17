return {
    'lfv89/vim-interestingwords',
    init = function()
        vim.g.interestingWordsDefaultMappings = 0
    end,
    keys = {
        { "<leader>k", ":call InterestingWords('n')<cr>", desc = "InterestingWords" },
        { "<leader>K", ":call UncolorAllWords()<cr>",     desc = "UncolorAllWords" }
    }
}
