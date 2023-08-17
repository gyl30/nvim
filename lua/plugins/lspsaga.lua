return {
    'nvimdev/lspsaga.nvim',
    config = function()
        require('lspsaga').setup({
            diagnostic = {
                diagnostic_only_current = true,
            },
        })
    end,
    dependencies = {
        'nvim-tree/nvim-web-devicons' -- optional
    }
}
