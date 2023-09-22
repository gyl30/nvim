local config = function()
    local attr = require("cokeline.hlgroups").get_hl_attr
    require('cokeline').setup({
        default_hl = {
            fg = function(buffer)
                return
                    buffer.is_focused
                    and attr('Normal', 'fg')
                    or attr('Comment', 'fg')
            end,
            bg = 'NONE',
        },

        components = {
            {
                text = function(buffer) return (buffer.index ~= 1) and '' or '' end,
                fg = attr('Normal', 'fg')
            },
            {
                text = function(buffer) return buffer.index .. ' ' end,
            },
            {
                text = function(buffer) return buffer.unique_prefix end,
                fg = attr('Comment', 'fg'),
                italic = true,
            },
            {
                text = function(buffer) return buffer.devicon.icon end,
                fg = function(buffer) return buffer.devicon.color end,
            },

            {
                text = function(buffer) return buffer.filename end,
                style = function(buffer) return buffer.is_focused and 'bold' or nil end,
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
        vim.api.nvim_set_keymap("n", ("<localleader>%s"):format(i), ("<Plug>(cokeline-focus-%s)"):format(i), { silent = true })
    end
end
return {
    "willothy/nvim-cokeline",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = config,
}
