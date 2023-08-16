local config = function()
    local get_hex = require('cokeline.utils').get_hex
    require('cokeline').setup({
        default_hl = {
            fg = function(buffer)
                return
                    buffer.is_focused
                    and get_hex('Normal', 'fg')
                    or get_hex('Comment', 'fg')
            end,
            bg = 'NONE',
        },

        components = {
            {
                text = function(buffer) return (buffer.index ~= 1) and '▏' or '' end,
                fg = get_hex('Normal', 'fg')
            },
            {
                text = function(buffer) return buffer.index .. ' ' end,
            },
            {
                text = function(buffer) return buffer.unique_prefix end,
                fg = get_hex('Comment', 'fg'),
                italic = true,
            },
            {
                text = function(buffer) return buffer.devicon.icon end,
                fg = function(buffer) return buffer.devicon.color end,
            },

            {
                text = function(buffer) return buffer.filename .. '  ' end,
                style = function(buffer) return buffer.is_focused and 'bold' or nil end,
            },
            {
                text = '',
                on_click = function(buffer)
                    buffer:delete()
                end,
                on_mouse_enter = function() vim.opt.mouse = 'a' end,
                on_mouse_enter = function() vim.opt.mouse = '' end,
            },
            {
                text = '  ',
            },
        },
    })
    local opt = { silent = true, expr = true }
    vim.keymap.set('n', '<tab>',
        function() return ('<Plug>(cokeline-focus-%s)'):format(vim.v.count > 0 and vim.v.count or 'next') end, opt)
    for i = 1, 9 do
        vim.api.nvim_set_keymap("n", ("<localleader>%s"):format(i), ("<Plug>(cokeline-focus-%s)"):format(i), opt)
    end
end
return {
    "willothy/nvim-cokeline",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = config,
}
