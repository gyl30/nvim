return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("fzf-lua").setup({
            fzf_opts         = {
                ['--info'] = 'default',
                ['--layout'] = 'reverse-list',
            },
            keymap           = {
                builtin = {
                    ['<C-a>'] = 'toggle-fullscreen',
                    ['<C-i>'] = 'toggle-preview',
                },
            },
            winopts          = {
                height = 0.8,
                width = 0.9,
                preview = {
                    scrollbar = false,
                    layout = 'vertical',
                    vertical = 'up:50%',
                },
            },
        })
        require("fzf-lua").register_ui_select()
    end
}
