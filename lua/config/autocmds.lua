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

vim.cmd([[
augroup CursorLineOnlyInActiveWindow
        autocmd!
        autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
        autocmd WinLeave * setlocal nocursorline
augroup END
]])
