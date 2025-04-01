vim.cmd [[
" 根据搜索结果折叠
nnoremap zpr :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>:set foldmethod=manual<CR><CR>
vnoremap // y/<c-r>"<CR>   "
function! ToUTF8()
    e ++ff=dos
    set fileencoding=utf-8
    set fileformat=unix
    w
endfunction
"autocmd BufWritePre *.cpp,*.lua,*.c,*.h,*.hpp :silent! call ToUTF8()
"autocmd BufWritePre *.cpp,*.lua,*.c,*.h,*.hpp :%retab
]]

vim.api.nvim_create_autocmd({ "FileType" }, {
    group = vim.api.nvim_create_augroup("FormatOptions", { clear = true }),
    pattern = { "*" },
    callback = function()
        vim.opt_local.fo:remove("o")
        vim.opt_local.fo:remove("r")
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "go to last loc when opening a buffer",
})
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
    callback = function()
        local ok, cl = pcall(vim.api.nvim_win_get_var, 0, "auto-cursorline")
        if ok and cl then
            vim.wo.cursorline = true
            vim.api.nvim_win_del_var(0, "auto-cursorline")
        end
    end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    callback = function()
        local cl = vim.wo.cursorline
        if cl then
            vim.api.nvim_win_set_var(0, "auto-cursorline", cl)
            vim.wo.cursorline = false
        end
    end,
})
vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("better_backup", { clear = true }),
    callback = function(event)
        local file = vim.loop.fs_realpath(event.match) or event.match
        local backup = vim.fn.fnamemodify(file, ":p:~:h")
        backup = backup:gsub("[/\\]", "%%")
        vim.go.backupext = backup
    end,
})

vim.api.nvim_create_autocmd({ "VimResized" }, {
    group = vim.api.nvim_create_augroup("user_resize_splits", { clear = true }),
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

vim.api.nvim_create_autocmd("CompleteDone", {
    pattern = "*.go",
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)

        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if next(r.edit) then
                    vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
                elseif next(r.command) then
                    vim.lsp.buf.execute_command(r.command)
                end
            end
        end
    end,
})

vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = vim.api.nvim_create_augroup("update_cmdheight", {}),
    callback = function()
        vim.opt_local.cmdheight = 1
    end,
})

if vim.fn.has("nvim-0.11") == 1 then
    vim.keymap.del({ "n" }, "grn")
    vim.keymap.del({ "n", "x" }, "gra")
    vim.keymap.del({ "n" }, "gri")
    vim.keymap.del({ "n" }, "grr")
    vim.keymap.del({ "n" }, "gO")
end

------------------------------------------ LSP KEYMAP ----------------------------------------------
local lsp_settings = function(ev)
    vim.keymap.set("n", "gd", function() require("fzf-lua").lsp_definitions({ jump1 = true }) end)
    vim.keymap.set("n", "gr",
        function() require("fzf-lua").lsp_references({ jump1 = true, ignore_current_line = true, includeDeclaration = false }) end)
    vim.keymap.set("n", "gi", function() require("fzf-lua").lsp_implementations() end)
    vim.keymap.set("n", "<leader>qf", function() require("fzf-lua").lsp_code_actions() end)
    vim.keymap.set("n", "<leader>d", function() require("fzf-lua").lsp_document_diagnostics() end)
    vim.keymap.set("n", "<leader>ws", function() require("fzf-lua").lsp_workspace_symbols() end)
    vim.keymap.set("n", "<leader>ic", function() require("fzf-lua").lsp_incoming_calls() end)
    vim.keymap.set("n", "<leader>oc", function() require("fzf-lua").lsp_outgoing_calls() end)
    vim.keymap.set("n", "<leader>ih", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
        return
    end
    if client.server_capabilities.documentFormattingProvider then
        if client.name ~= 'gopls' then
            vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format()<cr>')
        end
    end
    if client and client:supports_method('textDocument/foldingRange') then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldmethod = 'expr'
        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
    if client.name == 'ccls' then
        require("ccls").setup()
    end
end
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("user_fold_config", {}),
    callback = function(args)
        if not vim.w.lsp_folding_enabled then
            local has_parser, _ = pcall(vim.treesitter.get_parser, args.buf)
            if has_parser then
                vim.wo.foldmethod = 'expr'
                vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
            end
        end
    end,
})
vim.api.nvim_create_autocmd('LspDetach', { command = 'setl foldexpr<' })
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_lsp_config", {}),
    callback = lsp_settings
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'qf', 'snacks_dashboard' },
    callback = function()
        vim.keymap.set('n', 'q', '<cmd>bd<cr>', { silent = true, buffer = true })
    end,
})

vim.api.nvim_create_augroup("empty_buffer_quit_vim", { clear = true })
vim.api.nvim_create_autocmd("User", {
    pattern = "BDeletePre *",
    group = "empty_buffer_quit_vim",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
            vim.cmd "quit"
        end
    end,
})
