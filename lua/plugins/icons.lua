return {
    {

        'echasnovski/mini.icons',
        version = '*',
        config = function()
            require('mini.icons').setup({
                -- style = 'ascii',
            })
        end
    },
    { "nvim-tree/nvim-web-devicons", opts = {} },
}
