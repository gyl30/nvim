local function lsp_status()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    if next(clients) == nil then
        return '%#StlComponentInactive#[LS Inactive]%*'
    end
    local client_names = {}
    for _, client in ipairs(clients) do
        if client and client.name ~= '' then
            table.insert(client_names, string.format('%%#StlComponentOn#%s%%*', client.name))
        end
    end
    return string.format(' %s', table.concat(client_names, ', '))
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
local function search()
    if vim.v.hlsearch == 0 then
        return ''
    end
    local ok, s_count = pcall(vim.fn.searchcount, { recompute = true })
    if not ok or s_count.current == nil or s_count.total == 0 then
        return ''
    end
    if s_count.incomplete == 1 then
        return string.format('%%#StlIcon#%s [?/?]%%*', '')
    end
    local too_many = string.format('>%d', s_count.maxcount)
    local current = s_count.current > s_count.maxcount and too_many or s_count.current
    local total = s_count.total > s_count.maxcount and too_many or s_count.total
    return string.format('%%#StlIcon#%s [%s/%s]%%*', '', current, total)
end

local diagnostic_levels = { 'ERROR', 'WARN', 'INFO', 'HINT' }
local diagnostic_icons = { ERROR = '', WARN = '', INFO = '', HINT = '', }

local function diagnostic()
    local counts = vim.diagnostic.count(0)
    local res = {}
    for _, level in ipairs(diagnostic_levels) do
        local n = counts[vim.diagnostic.severity[level]] or 0
        if n > 0 then
            local icon = diagnostic_icons[level]
            if vim.diagnostic.is_enabled() then
                table.insert(res, string.format('%%#StlDiagnostic%s#%s %s%%*', level, icon, n))
            else
                table.insert(res, string.format('%%#StlComponentInactive#%s %s%%*', icon, n))
            end
        end
    end
    return table.concat(res, ' ')
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
        search(),
        diagnostic(),
        file_format(),
        encoding(),
        lsp_status(),
        progress(),
        location(),
        date()
    }, " ")
end

vim.o.statusline = "%{%v:lua._G.statusline()%}"
