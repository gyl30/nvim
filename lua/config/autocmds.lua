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
" autocmd BufWritePre *.cpp,*.lua,*.c,*.h,*.hpp,*.go :silent! call ToUTF8()
" autocmd BufWritePre *.cpp,*.lua,*.c,*.h,*.hpp :%retab
]]

vim.api.nvim_create_autocmd({ "FileType" }, {
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
        if vim.w.auto_cursorline then
            vim.wo.cursorline = true
            vim.w.auto_cursorline = nil
        end
    end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
    callback = function()
        if vim.wo.cursorline then
            vim.w.auto_cursorline = true
            vim.wo.cursorline = false
        end
    end,
})
vim.api.nvim_create_autocmd({ "VimResized" }, {
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

------------------------------------------ LSP KEYMAP ----------------------------------------------
local lsp_settings = function(client, buf)
    vim.keymap.set("n", "<leader>ih", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)

    local methods = vim.lsp.protocol.Methods

    if client:supports_method(methods.textDocument_documentHighlight) then
        local under_cursor_highlights_group =
            vim.api.nvim_create_augroup('CursorHighlights', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
            group = under_cursor_highlights_group,
            desc = 'Highlight references under the cursor',
            buffer = buf,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
            group = under_cursor_highlights_group,
            desc = 'Clear highlight references',
            buffer = buf,
            callback = vim.lsp.buf.clear_references,
        })
    end

    if client:supports_method(methods.textDocument_inlayHint) and vim.g.inlay_hints then
        local InlayHintsGroup = vim.api.nvim_create_augroup('ToggleInlayHints', { clear = false })
        vim.defer_fn(function()
            local mode = vim.api.nvim_get_mode().mode
            vim.lsp.inlay_hint.enable(mode == 'n' or mode == 'v', { bufnr = buf })
        end, 500)

        vim.api.nvim_create_autocmd('InsertEnter', {
            group = InlayHintsGroup,
            desc = 'Enable inlay hints',
            buffer = buf,
            callback = function()
                if vim.g.inlay_hints then
                    vim.lsp.inlay_hint.enable(false, { buffnr = buf })
                end
            end,
        })

        vim.api.nvim_create_autocmd('InsertLeave', {
            group = InlayHintsGroup,
            desc = 'Disable inlay hints',
            buffer = buf,
            callback = function()
                if vim.g.inlay_hints then
                    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
                end
            end,
        })
    end

    if client.server_capabilities.documentFormattingProvider then
        vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format()<cr>')
    end
    if client and client:supports_method('textDocument/foldingRange') then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldmethod = 'expr'
        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end

    if client.name == 'gopls' then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("GoplsSourceOrganizeImports", {}),
            callback = function()
                local params = {
                    textDocument = vim.lsp.util.make_text_document_params(0),
                    range = vim.lsp.util.make_range_params(0, 'utf-8').range,
                    context = {
                        only = { 'source.organizeImports' },
                        diagnostics = {},
                    },
                }
                local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 5000)
                for _, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                        if next(r.edit) then
                            vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
                        elseif next(r.command) then
                            client:exec_cmd({
                                title = "Organize Imports",
                                command = r.command,
                                arguments = { vim.api.nvim_buf_get_name(buf) },
                            })
                        end
                    end
                end
            end,
        })
    end
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup("UserFoldConfig", {}),
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
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
            return
        end
        lsp_settings(client, args.buf)
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'qf', 'snacks_dashboard' },
    callback = function()
        vim.keymap.set('n', 'q', '<cmd>bd<cr>', { silent = true, buffer = true })
    end,
})

vim.api.nvim_create_autocmd("User", {
    pattern = "BDeletePre *",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" then
            vim.cmd "quit"
        end
    end,
})
