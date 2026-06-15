return {
    "f-person/git-blame.nvim",
    keys = {
        {
            '<C-g>', mode = { 'n' }, silent = true, '<cmd>GitBlameToggle<cr>',
        }
    },
    opts = {
        enabled = false,
        message_template = " <summary> • <date> • <author> • <<sha>>",
        date_format = "%Y-%m-%d %H:%M:%S",
        virtual_text_column = 1,
    },
}
