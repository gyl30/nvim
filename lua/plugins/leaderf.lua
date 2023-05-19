local config = function()
    vim.g.Lf_GtagsAutoGenerate = 1
    vim.g.Lf_Gtagslabel = 'native-pygments'
    vim.g.Lf_UseCache = 0
    vim.g.Lf_HideHelp = 1
    vim.g.Lf_MruMaxFiles = 2048
    vim.g.Lf_WindowHeight = 0.30
    vim.g.Lf_UseMemoryCache = 0
    vim.g.Lf_ShowRelativePath = 0
    vim.g.Lf_UseVersionControlTool = 0
    vim.g.Lf_IgnoreCurrentBufferName = 1
    vim.g.Lf_PreviewResult = { Function = 0, BufTag = 0 }
    vim.g.Lf_StlSeparator = { left = '', right = '', font = '' }
    vim.g.Lf_WildIgnore = {
        dir = { '.git', '.clangd', '.svn', '.hg', '.cache', '.build', '.deps', '.ccls-cache', 'build' },
        file = { '*.exe', '*.o', '*.a', '*.so', '*.py[co]', '*.sw?', '*.bak', '*.d', '*.idx', "*.lint", '*.gcno' }
    }
    vim.g.Lf_WorkingDirectoryMode = 'AF'
    vim.g.Lf_RootMarkers = { '.git', '.svn', '.hg', '.project', '.root' }
    vim.g.Lf_NormalMap = {
        File = { { "<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>' } },
        Buffer = { { "<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>' } },
        Mru = { { "<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>' } },
        Tag = { { "<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>' } },
        Function = { { "<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>' } },
        Colorscheme = { { "<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>' } },
    }
    vim.cmd [[
    nnoremap <silent> <space>f :LeaderfFunction<cr>
    nnoremap <silent> <localleader>m :LeaderfMru<cr>
    ]]
end

return {
    "Yggdroot/LeaderF",
    build = ":LeaderfInstallCExtension",
    config = config,
    event =
    'VeryLazy',
}
