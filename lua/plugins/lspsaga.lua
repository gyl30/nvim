return {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
        require('lspsaga').setup({
            symbol_in_winbar = {
                hide_keyword = true,
            },
        })
    end,
    dependencies = {
        'nvim-tree/nvim-web-devicons' -- optional
    }
}
