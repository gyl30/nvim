return {
    "fatih/vim-go",
    build = ":GoUpdateBinaries",
    config = function()
        vim.g.go_echo_command_info = 0
    end
}
