return {
    "gyl30/translate",
    config = function()
        vim.cmd [[
            vmap <silent> <leader>t <Cmd>lua require("translate").translateV()<cr>
            nmap <silent> <leader>t <Cmd>lua require("translate").translateN()<cr>
            command! Translate  lua require("translate").translateN()
            command! TranslateV lua require("translate").translateV()
        ]]
    end
}
