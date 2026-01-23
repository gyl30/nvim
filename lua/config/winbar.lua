local M = {}

---@return string
function M.render()
    local current_file = vim.fn.expand '%:p'
    local path = vim.fs.normalize(current_file)

    if vim.startswith(path, 'diffview') then
        return string.format('%%#Winbar#%s', path)
    end

    local separator = ' %#WinbarSeparator# '

    local prefix = ''

    if vim.api.nvim_win_get_width(0) < math.floor(vim.o.columns / 3) then
        path = vim.fn.pathshorten(path)
    else
        local root = vim.fs.root(0, '.git')
        if root then
            root = vim.fs.normalize(root)
            local root_name = vim.fs.basename(root)
            prefix = string.format('%%#WinBarDir#%s %s%s', '󰉋', root_name, separator)
            path = path:gsub('^' .. vim.pesc(root), '')
        else
            local home = vim.fs.normalize(vim.env.HOME)
            if vim.startswith(path, home) then
                path = path:gsub('^' .. vim.pesc(home), '~')
            end
        end
    end

    path = path:gsub('^/', '')
    return table.concat {
        prefix,
        table.concat(
            vim.iter(vim.split(path, '/'))
            :map(function(segment)
                return string.format('%%#Winbar#%s', segment)
            end)
            :totable(),
            separator
        ),
    }
end

vim.api.nvim_create_autocmd('BufWinEnter', {
    group = vim.api.nvim_create_augroup('Winbar', { clear = true }),
    desc = 'Attach winbar',
    callback = function(args)
        if
            not vim.api.nvim_win_get_config(0).zindex
            and vim.bo[args.buf].buftype == ''
            and vim.api.nvim_buf_get_name(args.buf) ~= ''
            and not vim.wo[0].diff
        then
            vim.wo.winbar = "%{%v:lua.require'config.winbar'.render()%}"
        end
    end,
})

return M
