vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<leader>q", ":q!<cr>")
vim.keymap.set("n", "<space><space>", "%")

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<localleader>r', "<cmd>Telescope asynctasks all<cr>", opts)
vim.keymap.set('n', '<C-g>', "<cmd>GitBlameToggle<cr>", opts)
