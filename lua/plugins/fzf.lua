return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("fzf-lua").setup({
            winopts = {
                preview = {
                    layout = "vertical"
                }
            }
        })
        vim.api.nvim_create_autocmd("VimResized", {
            pattern = '*',
            command = 'lua require("fzf-lua").redraw()'
        })
        vim.keymap.set({ "n" }, "<C-x><C-f>",
            function()
                require("fzf-lua").lsp_finder({
                    winopts = {
                        preview = {
                            layout = "vertical",
                            vertical = "up"
                        }
                    }
                })
            end, { silent = true, desc = "Fuzzy lsp finder" })
        vim.keymap.set({ "n" }, "<C-x><C-g>",
            function()
                require("fzf-lua").git_files({
                    winopts = {
                        preview = {
                            layout = "horizontal"
                        }
                    }
                })
            end, { silent = true, desc = "Fuzzy git files" })
    end
}
