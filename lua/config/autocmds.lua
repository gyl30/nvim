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
command! BufOnly silent! execute "%bd|e#|bd#"
]]

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "*" },
    callback = function()
        vim.opt_local.fo:remove("o")
        vim.opt_local.fo:remove("r")
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('BigFile', { clear = true }),
    callback = function(args)
        vim.schedule(function()
            vim.bo[args.buf].syntax = vim.filetype.match { buf = args.buf } or ''
        end)
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = vim.api.nvim_create_augroup('LastLocation', { clear = true }),
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.cmd 'normal! g`"zz'
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
    vim.keymap.set('n', '<leader>lr', function() vim.cmd.lsp('restart') end, { buffer = buf })
    if client.server_capabilities.documentFormattingProvider then
        vim.keymap.set('n', '<leader>fm', '<cmd>lua vim.lsp.buf.format()<cr>')
    end
end


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
