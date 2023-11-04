vim.opt.fileencodings = 'utf8,ucs-bom,gbk,cp936,gb2312,gb18030'
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.showcmd = false
vim.opt.mouse = ''
vim.opt.cursorline = true
vim.opt.ttimeoutlen = 0
vim.opt.laststatus = 0
vim.opt.cmdheight = 1
vim.opt.showtabline = 0
vim.opt.showmode = false
vim.opt.autochdir = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.sidescroll = 10
vim.opt.colorcolumn = '100'
vim.opt.hidden = true
vim.opt.shortmess = 'aFc'
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.autowrite = true
vim.opt.confirm = true
vim.opt.langmenu = 'zh_CN.UTF-8'
vim.opt.fillchars = "vert:│"
vim.opt.virtualedit = { 'block', 'onemore' }
vim.opt.helplang = 'cn'
vim.opt.encoding = 'utf8'
vim.opt.updatecount = 100
vim.opt.updatetime = 300
vim.opt.signcolumn = "no"
vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.undofile = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.scrolloff = 15
vim.opt.list = true
vim.opt.listchars = 'tab:»·,nbsp:+,trail:·,extends:→,precedes:←'
vim.cmd [[
autocmd FileType * setlocal formatoptions-=o
]]
vim.opt.wildignore:append '*.pyc,*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib'
vim.opt.wildignore:append '*_build/*,*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex'
vim.opt.wildignore:append '***/coverage/*,*.log,*.pyc,*.sqlite,*.sqlite3,*.min.js,*.min.css,*.tags'
vim.opt.wildignore:append '***/node_modules/*,*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz'
vim.opt.wildignore:append '***/android/*,*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso'
vim.opt.wildignore:append '***/ios/*,*.pdf,*.dmg,*.app,*.ipa,*.apk,*.mobi,*.epub'
vim.opt.wildignore:append '***/.git/*,*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc'
vim.opt.wildignore:append '*.ppt,*.pptx,*.doc,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps'
vim.opt.wildignore:append '*/.git/*,*/.svn/*,*.DS_Store'
vim.opt.wildignore:append '*/node_modules/*,*/nginx_runtime/*,*/build/*,*/logs/*,*/dist/*,*/tmp/*'

local cache_dir = os.getenv('HOME') .. '/.cache/nvim/'
vim.opt.directory = cache_dir .. 'swag/'
vim.opt.undodir = cache_dir .. 'undo/'
vim.opt.backupdir = cache_dir .. 'backup/'
vim.opt.viewdir = cache_dir .. 'view/'
vim.opt.spellfile = cache_dir .. 'spell/en.uft-8.add'
vim.opt.clipboard = 'unnamedplus'

vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_gzip = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1


if vim.fn.executable('rg') == 1 then
    vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
    vim.opt.grepprg = 'rg --vimgrep --no-heading --smart-case'
end

local python2_dirs = { '/user/bin/python', '/usr/local/bin/python', '/home/linuxbrew/.linuxbrew/bin/python' }
local python3_dirs = { '/user/bin/python3', '/usr/local/bin/python3', '/home/linuxbrew/.linuxbrew/bin/python3' }

for index, dir in pairs(python2_dirs) do
    if vim.loop.fs_stat(dir) then
        vim.g.python_host_prog = dir
    end
end

for index, dir in pairs(python3_dirs) do
    if vim.loop.fs_stat(dir) then
        vim.g.python3_host_prog = dir
    end
end
