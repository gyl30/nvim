return {
    'nvimdev/lspsaga.nvim',
    event = "LspAttach",
    config = function()
        require('lspsaga').setup({
            symbol_in_winbar = {
                hide_keyword = true,
            },
            outline = {
                left_width = 0.5,
                layout = "float",
            },
            lightbulb = {
                sign = false,
            },
            rename = {
                in_select = false,
                auto_save = true,
            }
        })
    end,
    dependencies = {
        'nvim-tree/nvim-web-devicons' -- optional
    }
}
