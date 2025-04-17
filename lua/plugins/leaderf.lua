local leaderf_cfg = function()
    vim.g.Lf_GtagsAutoGenerate       = 1
    vim.g.Lf_Gtagslabel              = "native-pygments"
    vim.g.Lf_UseCache                = 0
    vim.g.Lf_HideHelp                = 1
    vim.g.Lf_MruMaxFiles             = 2048
    vim.g.Lf_WindowHeight            = 0.30
    vim.g.Lf_UseMemoryCache          = 0
    vim.g.Lf_ShowRelativePath        = 0
    vim.g.Lf_UseVersionControlTool   = 0
    vim.g.Lf_IgnoreCurrentBufferName = 1
    vim.g.Lf_WindowPosition          = 'popup'
    vim.g.Lf_PopupShowStatusline     = 0
    vim.g.Lf_PopupShowBorder         = 1
    vim.g.Lf_PopupBorders            = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' }
    vim.g.Lf_PopupWidth              = 0.8
    vim.g.Lf_PopupPosition           = { 0, 0 }
    vim.g.Lf_StlSeparator            = { left = "", right = "" }
    vim.g.Lf_PopupPreviewPosition    = 'top'
    vim.g.Lf_PreviewResult           = {
        File = 0,
        Mru = 0,
        Tag = 0,
        Function = 0,
        BufTag = 0,
        Colorscheme = 0,
        Line = 0,
        Rg = 0
    }
    vim.g.Lf_WildIgnore              = {
        dir = { ".git", ".clangd", ".svn", ".hg", ".cache", ".build", ".deps", ".ccls-cache", "build" },
        file = { "*.exe", "*.o", "*.a", "*.so", "*.py[co]", "*.sw?", "*.bak", "*.d", "*.idx", "*.lint", "*.gcno" },
    }
    vim.g.Lf_WorkingDirectoryMode    = "AF"
    vim.g.Lf_RootMarkers             = { ".git", ".svn", ".hg", ".project", ".root" }
    vim.g.Lf_NormalMap               = {
        File = { { "<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>' } },
        Buffer = { { "<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>' } },
        Mru = { { "<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>' } },
        Tag = { { "<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>' } },
        Function = { { "<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>' } },
        Colorscheme = { { "<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>' } },
    }
end

return {
    "Yggdroot/LeaderF",
    build = ":LeaderfInstallCExtension",
    config = leaderf_cfg,
    init = function()
        vim.g.Lf_ShortcutF = ""
        vim.g.Lf_ShortcutB = ""
    end,
    cmd = { 'LeaderfFile', "LeaderfFunction", "LeaderfMru" },
    keys = {
        { "<C-p>",          "<cmd>LeaderfFile<cr>",     desc = "LeaderfFile" },
        { "<localleader>f", "<cmd>LeaderfFunction<cr>", desc = "LeaderfFunction" },
        { "<localleader>m", "<cmd>LeaderfMru<cr>",      desc = "LeaderfMru" },
    },
}
