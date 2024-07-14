return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf_lua = require("fzf-lua")
        require("fzf-lua").setup({
            "borderless_full",
            actions = {
                files = {
                    ["ctrl-t"]  = fzf_lua.actions.file_tabedit,
                }
            },
            previewers = {
                man = {
                    cmd = "man %s | col -bx",
                }
            },
        })
        vim.api.nvim_create_autocmd("VimResized", {
            pattern = '*',
            command = 'lua require("fzf-lua").redraw()'
        })
    end
}
