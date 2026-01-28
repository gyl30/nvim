vim.g.mapleader = ' '
vim.g.maplocalleader = ';'
vim.cmd('mapclear')
vim.loader.enable()
require("config.keymaps")
require("config.plugin")
require("config.options")
require("config.autocmds")
require("config.statusline")
require("config.lsp")
require("config.winbar")
require("config.dashboard").setup()
require("config.bufferline").setup()
vim.cmd [[
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175
    colorscheme slate
    highlight ModeMsg     guibg=NONE guibg=NONE ctermfg=10 guifg=NvimLightGreen
    highlight Normal      guibg=NONE
    highlight MatchParen  guibg=NONE guifg=yellow gui=underline
    highlight NormalFloat guibg=NONE
    highlight FloatBorder guibg=NONE
    highlight TabLineFill guifg=NONE guibg=NONE ctermfg=210 ctermbg=236
]]
