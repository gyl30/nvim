return {
    "mbbill/undotree",
    event = 'VeryLazy',
    config = function()
        vim.keymap.set('n', '<localleader>ud', vim.cmd.UndotreeToggle)
    end
}
