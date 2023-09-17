return {
    'lfv89/vim-interestingwords',
    init = function()
        vim.g.interestingWordsDefaultMappings = 0
    end,
    config = function()
        vim.cmd [[
            nnoremap <silent> <leader>k :call InterestingWords('n')<cr>
            vnoremap <silent> <leader>k :call InterestingWords('v')<cr>
            nnoremap <silent> <leader>K :call UncolorAllWords()<cr>
        ]]
    end
}
