return {
    'voldikss/vim-floaterm',
    cmd = { 'FloatermToggle', 'FloatermNew' },
    keys = {
        {
            '<leader>ft',
            mode = { 'n' },
            silent = true,
            '<cmd>FloatermToggle<cr>',
            desc = 'Floating Terminal'
        },
    },
    init = function()
        vim.g.floaterm_width = 0.85
        vim.g.floaterm_height = 0.85
        vim.g.floaterm_title = ''
        vim.g.floaterm_titleposition = 'center'
    end
}
