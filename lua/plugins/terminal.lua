return {
    'voldikss/vim-floaterm',
    cmd = { 'FloatermToggle', 'FloatermNew' },
    keys = {
        {
            '<leader>ft',
            mode = { 'n' },
            silent = true,
            function()
                local current_floatterm_bufnr = vim.fn['floaterm#buflist#curr']()
                if current_floatterm_bufnr == -1 then
                    -- 新建终端
                    vim.cmd('FloatermNew --cwd=<root>')
                else
                    -- 复用已经存在的终端
                    vim.cmd { cmd = 'FloatermToggle', args = { tostring(current_floatterm_bufnr) } }
                end
            end,
            desc = 'Floating Terminal'
        },
    },
    init = function()
        vim.g.floaterm_width = 0.85
        vim.g.floaterm_height = 0.85
        vim.g.floaterm_title = ''
        vim.g.floaterm_titleposition = 'center'
    end,
    config = function()
        vim.keymap.set('t', '<ESC>', '<cmd>FloatermToggle<cr>', { noremap = true })
    end
}
