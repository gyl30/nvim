vim.opt.number = true
vim.opt.showcmd = false
vim.opt.mouse = ''
vim.opt.cursorline = true
vim.opt.ttimeoutlen = 0
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.showtabline = 0
vim.opt.showmode = false
vim.opt.autochdir = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.colorcolumn = '100'
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.autowrite = true
vim.opt.updatecount = 100
vim.opt.updatetime = 300
vim.opt.signcolumn = "no"

vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

vim.opt.undofile = true
vim.opt.completeopt = "menu,menuone,noselect"

vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

local python2_dirs = { '/user/bin/python', '/usr/local/bin/python', '/home/linuxbrew/.linuxbrew/bin/python' }
local python3_dirs = { '/user/bin/python3', '/usr/local/bin/python3', '/home/linuxbrew/.linuxbrew/bin/python3' }

for _, dir in pairs(python2_dirs) do
    if vim.loop.fs_stat(dir) then
        vim.g.python_host_prog = dir
    end
end

for _, dir in pairs(python3_dirs) do
    if vim.loop.fs_stat(dir) then
        vim.g.python3_host_prog = dir
    end
end
