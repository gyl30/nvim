return {
    'echasnovski/mini.bufremove',
    keys = {
        { '<leader>bd', function() require('mini.bufremove').delete(0, false) end, desc = 'Delete buffer' },
        { '<leader>bk', function() require('mini.bufremove').delete(0, false) end, desc = 'Delete buffer' },
        { '<leader>bD', function() require('mini.bufremove').delete(0, true) end,  desc = 'Delete buffer (force)' },
        { '<leader>bK', function() require('mini.bufremove').delete(0, true) end,  desc = 'Delete buffer (force)' },
    },
    config = function()
        require('mini.bufremove').setup()
    end,
}
