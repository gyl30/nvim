local config = function() vim.cmd [[ nnoremap <silent> <localleader>n :LazyGit<CR> ]] end

return {
    "kdheepak/lazygit.nvim", config = config
}
