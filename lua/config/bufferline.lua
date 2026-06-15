local M = {}

M.first_visible_idx = 1

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, {
        title = "bufferline",
    })
end

local function is_valid_buf(buf)
    return type(buf) == "number" and vim.api.nvim_buf_is_valid(buf)
end

local function is_valid_win(win)
    return type(win) == "number" and vim.api.nvim_win_is_valid(win)
end

local function is_listed_buf(buf)
    return is_valid_buf(buf) and vim.bo[buf].buflisted
end

local function normalize_buf(buf)
    if buf == nil or buf == 0 then
        return vim.api.nvim_get_current_buf()
    end

    return buf
end

function M.get_buffers()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })

    table.sort(bufs, function(a, b)
        return a.bufnr < b.bufnr
    end)

    return bufs
end

local function get_listed_buffer_numbers()
    local result = {}

    for _, buf in ipairs(M.get_buffers()) do
        if is_valid_buf(buf.bufnr) then
            table.insert(result, buf.bufnr)
        end
    end

    return result
end

local function create_empty_buf()
    local buf = vim.api.nvim_create_buf(true, false)

    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false

    return buf
end

local function find_replacement_buf(target_buf)
    local alt = vim.fn.bufnr("#")

    if alt > 0 and alt ~= target_buf and is_listed_buf(alt) then
        return alt
    end

    for _, buf in ipairs(get_listed_buffer_numbers()) do
        if buf ~= target_buf and is_valid_buf(buf) then
            return buf
        end
    end

    return nil
end

local function unshow_in_window(win, target_buf)
    if not is_valid_win(win) then
        return
    end

    vim.api.nvim_win_call(win, function()
        if vim.fn.getcmdwintype() ~= "" then
            vim.cmd("close!")
            return
        end

        local current_buf = vim.api.nvim_win_get_buf(win)

        if current_buf ~= target_buf then
            return
        end

        local replacement = find_replacement_buf(target_buf)

        if replacement then
            vim.api.nvim_win_set_buf(win, replacement)
            return
        end

        vim.api.nvim_win_set_buf(win, create_empty_buf())
    end)
end

local function unshow_buffer(buf)
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        unshow_in_window(win, buf)
    end
end

local function has_unsaved_change(buf)
    return is_valid_buf(buf) and vim.bo[buf].modified
end

local function remove_buffer(buf, force, command)
    buf = normalize_buf(buf)
    force = force == true

    if not is_valid_buf(buf) then
        notify("无效 buffer: " .. tostring(buf), vim.log.levels.ERROR)
        return false
    end

    if has_unsaved_change(buf) and not force then
        notify("当前 buffer 有未保存修改，使用 :Bdelete! 强制关闭", vim.log.levels.WARN)
        return false
    end

    unshow_buffer(buf)

    local ok, err = pcall(function()
        vim.cmd({
            cmd = command,
            bang = force,
            args = { tostring(buf) },
        })
    end)

    if not ok then
        local msg = tostring(err)

        -- 有些特殊 buffer 在 unshow 阶段可能已经被删除。
        if msg:find("E516") or msg:find("E517") or msg:find("E89") then
            vim.cmd("redrawtabline")
            return true
        end

        notify(msg, vim.log.levels.ERROR)
        return false
    end

    vim.cmd("redrawtabline")

    return true
end

function M.delete_buffer(buf, force)
    return remove_buffer(buf, force, "bdelete")
end

function M.delete_current_buffer(force)
    return M.delete_buffer(0, force)
end

function M.wipeout_buffer(buf, force)
    return remove_buffer(buf, force, "bwipeout")
end

function M.wipeout_current_buffer(force)
    return M.wipeout_buffer(0, force)
end

function M.goto_buffer(index)
    local bufs = M.get_buffers()
    local buf = bufs[index]

    if buf then
        vim.api.nvim_set_current_buf(buf.bufnr)
    end
end

function M.next_buffer()
    local bufs = M.get_buffers()

    if #bufs == 0 then
        return
    end

    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(bufs) do
        if buf.bufnr == current then
            local next_i = i % #bufs + 1
            vim.api.nvim_set_current_buf(bufs[next_i].bufnr)
            return
        end
    end

    vim.api.nvim_set_current_buf(bufs[1].bufnr)
end

function M.prev_buffer()
    local bufs = M.get_buffers()

    if #bufs == 0 then
        return
    end

    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(bufs) do
        if buf.bufnr == current then
            local prev_i = (i - 2 + #bufs) % #bufs + 1
            vim.api.nvim_set_current_buf(bufs[prev_i].bufnr)
            return
        end
    end

    vim.api.nvim_set_current_buf(bufs[1].bufnr)
end

function M.setup_highlight()
    vim.api.nvim_set_hl(0, "SelfBufferLineSel", { link = "TabLineSel" })
    vim.api.nvim_set_hl(0, "SelfBufferLine", { link = "TabLine" })
    vim.api.nvim_set_hl(0, "SelfBufferLineFill", { link = "TabLineFill" })
    vim.api.nvim_set_hl(0, "SelfBufferLineSep", { link = "Comment" })
end

function M.render()
    local current = vim.api.nvim_get_current_buf()
    local buf_type = vim.bo[current].buftype
    local buf_name = vim.api.nvim_buf_get_name(current)

    if buf_type ~= "" or buf_name == "" then
        return ""
    end

    local bufs = M.get_buffers()

    if #bufs == 0 then
        return ""
    end

    if M.first_visible_idx > #bufs then
        M.first_visible_idx = #bufs
    elseif M.first_visible_idx < 1 then
        M.first_visible_idx = 1
    end

    local segments = {}
    local current_idx = 1

    for i, buf in ipairs(bufs) do
        local name = vim.fn.fnamemodify(buf.name, ":t")

        if name == "" then
            name = "[No Name]"
        end

        local modified = vim.bo[buf.bufnr].modified and " ●" or ""
        local text = " " .. i .. ":" .. name .. modified .. " "
        local width = vim.fn.strdisplaywidth(text) + 1

        if buf.bufnr == current then
            current_idx = i
        end

        table.insert(segments, {
            text = text,
            width = width,
            is_current = buf.bufnr == current,
        })
    end

    local max_screen_width = vim.o.columns - 6

    if current_idx < M.first_visible_idx then
        M.first_visible_idx = current_idx
    end

    while true do
        local current_total_width = 0

        for i = M.first_visible_idx, current_idx do
            current_total_width = current_total_width + segments[i].width
        end

        if current_total_width > max_screen_width and M.first_visible_idx < current_idx then
            M.first_visible_idx = M.first_visible_idx + 1
        else
            break
        end
    end

    local s = ""
    local current_render_width = 0

    if M.first_visible_idx > 1 then
        s = s .. "%#SelfBufferLineSep#< |"
    end

    for i = M.first_visible_idx, #segments do
        local seg = segments[i]

        if current_render_width + seg.width > max_screen_width then
            s = s .. "%#SelfBufferLineSep#> "
            break
        end

        if seg.is_current then
            s = s .. "%#SelfBufferLineSel#" .. seg.text
        else
            s = s .. "%#SelfBufferLineSep#" .. seg.text
        end

        if i ~= #segments then
            s = s .. "%#SelfBufferLineSep#|"
        end

        current_render_width = current_render_width + seg.width
    end

    s = s .. "%#SelfBufferLineFill#"

    return s
end

function M.setup()
    M.setup_highlight()
    vim.o.showtabline = 2
    vim.o.tabline = "%!v:lua.require'config.bufferline'.render()"
end

return M
