return {
    "mhinz/vim-startify",
    lazy = true,
    event = "VimEnter",
    config = function()
        vim.cmd[[
            let g:startify_custom_header ='startify#center(startify#fortune#cowsay())'
        ]]
    end
}
