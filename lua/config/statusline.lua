local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return "No Active Lsp"
    end
    local it = vim.iter(attached_clients)
    it:map(function(client)
        local name = client.name:gsub("language.server", "ls")
        return name
    end)
    local names = it:totable()
    local clinet_name = ""
    for _, name in pairs(names) do
        clinet_name = clinet_name .. ' ' .. string.lower(name)
    end
    return clinet_name
end
local function file_format()
    local symbols = {
        unix = 'UNIX',
        dos = 'DOS',
        mac = 'MAC',
    }
    local os = vim.bo.fileformat
    return symbols[os] or ''
end
local function progress()
    local cur = vim.fn.line('.')
    local total = vim.fn.line('$')
    if cur == 1 then
        return 'Top'
    elseif cur == total then
        return 'Bot'
    else
        return string.format('%2d%%%%', math.floor(cur / total * 100))
    end
end

local function location()
    local line = vim.fn.line('.')
    local col = vim.fn.charcol('.')
    if line < 100 then
        return string.format('%2d:%-2d', line, col)
    end
    return string.format('%3d:%-2d', line, col)
end
local function encoding()
    local result = vim.opt.fileencoding:get()
    result = string.upper(result)
    if vim.opt.bomb:get() then
        result = result .. ' [BOM]'
    end
    return result
end

local function date()
    return " " .. os.date("%R")
end

local mode = {
    ['n']     = 'NORMAL',
    ['no']    = 'O-PENDING',
    ['nov']   = 'O-PENDING',
    ['noV']   = 'O-PENDING',
    ['no\22'] = 'O-PENDING',
    ['niI']   = 'NORMAL',
    ['niR']   = 'NORMAL',
    ['niV']   = 'NORMAL',
    ['nt']    = 'NORMAL',
    ['ntT']   = 'NORMAL',
    ['v']     = 'VISUAL',
    ['vs']    = 'VISUAL',
    ['V']     = 'V-LINE',
    ['Vs']    = 'V-LINE',
    ['\22']   = 'V-BLOCK',
    ['\22s']  = 'V-BLOCK',
    ['s']     = 'SELECT',
    ['S']     = 'S-LINE',
    ['\19']   = 'S-BLOCK',
    ['i']     = 'INSERT',
    ['ic']    = 'INSERT',
    ['ix']    = 'INSERT',
    ['R']     = 'REPLACE',
    ['Rc']    = 'REPLACE',
    ['Rx']    = 'REPLACE',
    ['Rv']    = 'V-REPLACE',
    ['Rvc']   = 'V-REPLACE',
    ['Rvx']   = 'V-REPLACE',
    ['c']     = 'COMMAND',
    ['cv']    = 'EX',
    ['ce']    = 'EX',
    ['r']     = 'REPLACE',
    ['rm']    = 'MORE',
    ['r?']    = 'CONFIRM',
    ['!']     = 'SHELL',
    ['t']     = 'TERMINAL',
}

local function status_mode()
    local code = vim.api.nvim_get_mode().mode
    if mode[code] == nil then
        return code
    end
    return mode[code]
end
function _G.statusline()
    return table.concat({
        status_mode(),
        "%f",
        "%=",
        file_format(),
        encoding(),
        lsp_status(),
        progress(),
        location(),
        date()
    }, " ")
end

vim.o.statusline = "%{%v:lua._G.statusline()%}"
