vim.keymap.set("n", "<leader>q", ":q!<cr>")
vim.keymap.set("n", "<space><space>", "%")
vim.keymap.set('n', 'H', ':bprev<CR>', { desc = 'Prev buffer', noremap = false })
vim.keymap.set('n', 'L', ':bnext<CR>', { desc = 'Next buffer', noremap = false })
vim.keymap.set('n', 'c', '"_c')
vim.keymap.set('n', 'C', '"_C')
vim.keymap.set('n', 'cc', '"_cc')
vim.keymap.set('x', 'c', '"_c')
vim.keymap.set('x', 'p', 'p:let @+=@0<CR>:let @"=@0<CR>')
vim.keymap.set('n', '=', [[:vertical resize +5<CR>]])
vim.keymap.set('n', '-', [[:vertical resize -5<CR>]])
vim.keymap.set('n', '+', [[:horizontal resize +2<CR>]])
vim.keymap.set('n', '_', [[:horizontal resize -2<CR>]])
vim.keymap.set('i', '<C-h>', '<Left>', { desc = 'Move left' })
vim.keymap.set('i', '<C-l>', '<Right>', { desc = 'Move right' })
vim.keymap.set('i', '<C-j>', '<Down>', { desc = 'Move down' })
vim.keymap.set('i', '<C-k>', '<Up>', { desc = 'Move up' })
local function smart_jk(jk)
    if vim.v.count ~= 0 then
        if vim.v.count > 5 then
            return "m'" .. vim.v.count .. jk
        end
        return jk
    end
    return 'g' .. jk
end

local function smart_del(key)
    local cmd = key .. key
    if vim.api.nvim_get_current_line():match('^%s*$') then
        return '"_' .. cmd
    else
        return cmd
    end
end

vim.keymap.set('n', 'j', function() return smart_jk('j') end, { expr = true })
vim.keymap.set('n', 'k', function() return smart_jk('k') end, { expr = true })
vim.keymap.set('n', 'dd', function() return smart_del('d') end, { expr = true })
vim.keymap.set('n', 'cc', function() return smart_del('c') end, { expr = true })
vim.keymap.set('n', 'i', function()
    if #vim.fn.getline('.') == 0 then
        return [["_cc]]
    else
        return 'i'
    end
end, { expr = true })
