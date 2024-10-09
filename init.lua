vim.g.mapleader = ' '
vim.g.maplocalleader = ';'
require("config.keymaps")
require("config.plugin")
require("config.options")
require("config.autocmds")
require("config.statusline")
require("config.neovide")
vim.cmd [[
    colorscheme slate
    source ~/.config/nvim/task.vim
    highlight ModeMsg     guibg=NONE guibg=NONE ctermfg=10 guifg=NvimLightGreen
    highlight Normal      guibg=NONE
    highlight MatchParen  guibg=NONE guifg=yellow gui=underline
    highlight NormalFloat guibg=NONE
    highlight FloatBorder guibg=NONE
    highlight TabLineFill guifg=NONE guibg=NONE ctermfg=210 ctermbg=236
]]


