vim.cmd [[
" 打开文件自动定位到最后编辑的位置
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif
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

vim.keymap.set("n", "<localleader>bb", function()
    local cnt = 0
    local blink_times = 7
    local timer = vim.loop.new_timer()

    timer:start(0, 100, vim.schedule_wrap(function()
        vim.cmd [[
            set cursorcolumn!
            set cursorline!
        ]]

        if cnt == blink_times then
            timer:close()
        end

        cnt = cnt + 1
    end))
end)

-- show cursor line only in active window
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
-- create directories when needed, when saving a file
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

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_close_with_q", { clear = true }),
    pattern = {
        "PlenaryTestPopup",
        "help",
        "lspinfo",
        "man",
        "notify",
        "qf",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "neotest-output",
        "checkhealth",
        "neotest-summary",
        "neotest-output-panel",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Fix conceallevel for json & help files
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "json", "jsonc" },
    callback = function()
        vim.wo.spell = false
        vim.wo.conceallevel = 0
    end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "cpp", "c","go","cmake","bash","lua" },
    callback = function()
        vim.wo.signcolumn = "no"
        vim.diagnostic.open_float(nil, { focusable = false })
    end,
})

vim.cmd [[
set signcolumn=no
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]]

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
  end
})
