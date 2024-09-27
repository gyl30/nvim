vim.g.mapleader = ' '
vim.g.maplocalleader = ';'
require("config.keymaps")
require("config.plugin")
require("config.options")
require("config.autocmds")
require("config.statusline")
vim.cmd [[
source ~/.config/nvim/task.vim
]]
