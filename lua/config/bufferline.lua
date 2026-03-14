local M = {}

M.first_visible_idx = 1

local function get_buffers()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })

    table.sort(bufs, function(a, b)
        return a.bufnr < b.bufnr
    end)

    return bufs
end

function M.goto_buffer(index)
    local bufs = get_buffers()
    local buf = bufs[index]
    if buf then
        vim.api.nvim_set_current_buf(buf.bufnr)
    end
end

function M.next_buffer()
    local bufs = get_buffers()
    if #bufs == 0 then return end

    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(bufs) do
        if buf.bufnr == current then
            local next_i = i % #bufs + 1
            vim.api.nvim_set_current_buf(bufs[next_i].bufnr)
            return
        end
    end
end

function M.prev_buffer()
    local bufs = get_buffers()
    if #bufs == 0 then return end

    local current = vim.api.nvim_get_current_buf()

    for i, buf in ipairs(bufs) do
        if buf.bufnr == current then
            local prev_i = (i - 2 + #bufs) % #bufs + 1
            vim.api.nvim_set_current_buf(bufs[prev_i].bufnr)
            return
        end
    end
end

local function setup_highlight()
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

    local bufs = get_buffers()
    if #bufs == 0 then return "" end

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
            is_current = (buf.bufnr == current)
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
    setup_highlight()

    vim.o.showtabline = 2
    vim.o.tabline = "%!v:lua.require'config.bufferline'.render()"

    for i = 1, 9 do
        vim.keymap.set("n", "<localleader>" .. i, function()
            M.goto_buffer(i)
        end, { silent = true, desc = "Go to buffer " .. i })
    end

    vim.keymap.set("n", "<Tab>", M.next_buffer, { silent = true })
    vim.keymap.set("n", "<S-Tab>", M.prev_buffer, { silent = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            setup_highlight()
        end,
    })
end

return M
