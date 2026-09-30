vim.cmd [[
" 根据搜索结果折叠
nnoremap zpr :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>:set foldmethod=manual<CR><CR>
vnoremap // y/<c-r>"<CR>   "
command! BufOnly silent! execute "%bd|e#|bd#"
]]

vim.opt.fileencodings = {
    "ucs-bom",
    "utf-8",
    "gb18030",
    "gbk",
    "cp936",
    "latin1",
}

vim.opt.fileformats = {
    "unix",
    "dos",
    "mac",
}

vim.api.nvim_create_user_command("ToUTF8", function()
    vim.bo.fileencoding = "utf-8"
    vim.bo.fileformat = "unix"
    vim.cmd.write()
end, {})
vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
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

vim.api.nvim_create_autocmd('VimResized', {
    group = vim.api.nvim_create_augroup(
        'EqualizeWindows',
        { clear = true }
    ),
    callback = function()
        vim.cmd('wincmd =')
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup(
        'AutoCreateDir',
        { clear = true }
    ),
    callback = function(ctx)
        if ctx.file:find('://', 1, true) then
            return
        end

        vim.fn.mkdir(
            vim.fn.fnamemodify(ctx.file, ':p:h'),
            'p'
        )
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
