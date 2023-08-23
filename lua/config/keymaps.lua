vim.cmd [[
    nnoremap <space><space> %
    nnoremap <C-h> <C-w>h
    nnoremap <C-l> <C-w>l
    nnoremap <C-j> <C-w>j
    nnoremap <C-k> <C-w>k
    nnoremap <leader>q :q!<CR>
]]


local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<localleader>r', "<cmd>Telescope asynctasks all<cr>", opts)
