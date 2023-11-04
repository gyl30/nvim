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

vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.signcolumn = "no"
        vim.diagnostic.open_float(nil, { show_header = false, severity_sort = true, scope = "line", focusable = false })
    end,
})

------------------------------------------ LSP AUTOFORMAT ----------------------------------------------
local lsp_autoformat = function(client_id, client_name, bufnr)
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup(client_name .. "_autoformat", { clear = false }),
        buffer = bufnr,
        callback = function()
            vim.lsp.buf.format {
                async = false,
                filter = function(c)
                    return c.id == client_id
                end,
            }
        end,
    })
end

-- https://github.com/neovim/nvim-lspconfig/issues/115
local gopls_enable_autoformat = function(bufnr)
    local format_func = function()
        local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
        params.context = { only = { "source.organizeImports" } }
        local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
        for _, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
                else
                    vim.lsp.buf.execute_command(r.command)
                end
            end
        end
        vim.lsp.buf.format()
    end
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("gopls_autoformat", { clear = false }),
        buffer = bufnr,
        callback = format_func,
    })
end

------------------------------------------ LSP KEYMAP ----------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_lsp_config", {}),
    callback = function(ev)
        local opts = { buffer = ev.buf, noremap = true, silent = true }
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', 'gr', function() builtin.lsp_references({ include_current_line = false }) end, opts)
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
        vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename  ++project<cr>", opts)
        vim.keymap.set('n', '<leader>d', "<cmd>Lspsaga show_buf_diagnostics<cr>", opts)
        vim.keymap.set('n', '<leader>qf', "<cmd>Lspsaga code_action<cr>", opts)
        vim.keymap.set('n', '<leader>l', "<cmd>LspLensToggle<cr>", opts)
        -- format autocmd
        local client_id = ev.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        if not client.server_capabilities.documentFormattingProvider then
            return
        end
        if client.name == 'gopls' then
            gopls_enable_autoformat(ev.buf)
        else
            lsp_autoformat(client_id, client.name, ev.buf)
        end
    end,
})
