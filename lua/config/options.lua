vim.opt.number = false
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
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.colorcolumn = '100'
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
vim.opt.virtualedit = 'onemore'

vim.opt.undofile = true
vim.opt.completeopt = "menu,menuone,noselect"

vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

local python2_list = { '/user/bin/python', '/usr/local/bin/python', '/home/linuxbrew/.linuxbrew/bin/python' }
local python3_list = { '/user/bin/python3', '/usr/local/bin/python3', '/home/linuxbrew/.linuxbrew/bin/python3' }

for _, py in pairs(python2_list) do
    if vim.fn.executable(py) then
        vim.g.python_host_prog = py
    end
end

for _, py in pairs(python3_list) do
    if vim.fn.executable(py) then
        vim.g.python3_host_prog = py
    end
end
