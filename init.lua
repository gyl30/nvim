vim.g.mapleader = ' '
vim.g.maplocalleader = ';'
require("config.keymaps")
require("config.plugin")
require("config.theme")
require("config.options")
require("config.autocmds")
require("config.mappings")
vim.cmd [[
source ~/.config/nvim/task.vim
]]
