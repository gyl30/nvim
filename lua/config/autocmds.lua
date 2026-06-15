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

vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
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

vim.api.nvim_create_autocmd({ 'VimResized' }, {
    callback = function()
        vim.cmd('tabdo wincmd =')
    end,
})
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = '*',
    group = vim.api.nvim_create_augroup('AutoCreateDir', {}),
    callback = function(ctx)
        if vim.bo.ft == 'oil' then
            return
        end
        local dir = vim.fn.fnamemodify(ctx.file, ':p:h')
        local res = vim.fn.isdirectory(dir)
        if res == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
})

vim.api.nvim_create_user_command("Bdelete", function(opts)
    require("config.bufferline").delete_current_buffer(opts.bang)
end, {
    bang = true,
    desc = "Delete current buffer without closing window",
})

vim.api.nvim_create_user_command("Bwipeout", function(opts)
    require("config.bufferline").wipeout_current_buffer(opts.bang)
end, {
    bang = true,
    desc = "Wipeout current buffer without closing window",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("BufferLineHighlight", { clear = true }),
    callback = function()
        require("config.bufferline").setup_highlight()
    end,
})
