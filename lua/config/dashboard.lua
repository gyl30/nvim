local M = {}

local SHOW_COUNT = 9
local VISUAL_OFFSET = 2
local DASH_AU_GROUP = vim.api.nvim_create_augroup("SelfDashboard", { clear = true })

local file_map = {}
local valid_lines = {}
local last_cursor_row = 0

local function str_width(str) return vim.fn.strdisplaywidth(str) end
local function spaces(n) return string.rep(" ", n) end

local function shorten_path(path)
    local home = vim.fn.expand("~")
    local display_path = path:gsub("^" .. vim.pesc(home), "~")
    local parts = vim.split(display_path, "/", { trimempty = true })
    if #parts <= 1 then return display_path end

    local filename = table.remove(parts)
    local result = {}
    for i, part in ipairs(parts) do
        if i == 1 and part == "~" then
            table.insert(result, "~")
        else
            local short = part:sub(1, part:sub(1, 1) == "." and 2 or 1)
            table.insert(result, short)
        end
    end
    table.insert(result, filename)
    return table.concat(result, "/")
end

local function align_center_block(lines)
    local win_width = vim.api.nvim_win_get_width(0)
    local max_width = 0
    for _, line in ipairs(lines) do
        local w = str_width(line)
        if w > max_width then max_width = w end
    end
    local padding_len = math.max(0, math.floor((win_width - max_width) / 2))
    local padding = spaces(padding_len)
    local new_lines = {}
    for _, line in ipairs(lines) do table.insert(new_lines, padding .. line) end
    return new_lines, padding_len
end

local function get_lazy_stats_info()
    local ok, lazy_stats = pcall(require, "lazy.stats")
    if not ok then return nil end
    local stats = lazy_stats.stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

    return {
        prefix = "⚡ Neovim loaded ",
        stats = string.format("%d/%d", stats.loaded, stats.count),
        middle = " plugins in ",
        time = ms .. "ms"
    }
end

local function lock_cursor(buf, target_col)
    vim.api.nvim_clear_autocmds({ group = DASH_AU_GROUP, buffer = buf })
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = DASH_AU_GROUP,
        buffer = buf,
        callback = function()
            if vim.bo.filetype ~= 'dashboard' then return end
            local cursor = vim.api.nvim_win_get_cursor(0)
            local cur_row = cursor[1]
            local target_row = last_cursor_row

            if file_map[cur_row] then
                target_row = cur_row
            else
                if cur_row > last_cursor_row then
                    for _, v in ipairs(valid_lines) do
                        if v > last_cursor_row then
                            target_row = v; break
                        end
                    end
                elseif cur_row < last_cursor_row then
                    for i = #valid_lines, 1, -1 do
                        if valid_lines[i] < last_cursor_row then
                            target_row = valid_lines[i]; break
                        end
                    end
                end
            end
            last_cursor_row = target_row
            pcall(vim.api.nvim_win_set_cursor, 0, { target_row, target_col })
        end,
    })
end

function M.draw()
    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].filetype = 'dashboard'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].buflisted = false
    vim.bo[buf].swapfile = false

    local current_cwd = vim.fn.getcwd()
    local oldfiles = vim.v.oldfiles
    local section1 = {}
    local section2 = {}

    for _, f in ipairs(oldfiles) do
        if vim.fn.filereadable(f) == 1 then
            if #section1 < SHOW_COUNT then table.insert(section1, f) end
            if #section2 < SHOW_COUNT and vim.startswith(f, current_cwd) then
                table.insert(section2, f)
            end
        end
    end

    local raw_lines = {}
    local line_metadata = {}

    local function add(text, type, data)
        table.insert(raw_lines, text)
        table.insert(line_metadata, { type = type, data = data, text = text })
    end

    add("MRU", "header")
    add("", "empty")
    for _, f in ipairs(section1) do add("  " .. shorten_path(f), "file", f) end
    add("", "empty")
    add("", "empty")
    add("MRU " .. vim.fn.fnamemodify(current_cwd, ":~"), "header")
    add("", "empty")
    if #section2 == 0 then
        add("", "empty")
    else
        for _, f in ipairs(section2) do add("  " .. shorten_path(f), "file", f) end
    end

    local stats = get_lazy_stats_info()
    if stats then
        add("", "empty")
        add("", "empty")
        local footer_text = stats.prefix .. stats.stats .. stats.middle .. stats.time
        add(footer_text, "footer", stats)
    end

    local content, padding_left = align_center_block(raw_lines)
    local win_height = vim.api.nvim_win_get_height(0)
    local padding_top = math.max(0, math.floor((win_height - #content) / 2) - VISUAL_OFFSET)

    local final_lines = {}
    for _ = 1, padding_top do table.insert(final_lines, "") end
    for _, l in ipairs(content) do table.insert(final_lines, l) end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, final_lines)
    vim.bo[buf].modifiable = false

    file_map = {}
    valid_lines = {}
    local ns_id = vim.api.nvim_create_namespace("DashboardHL")
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

    for i, meta in ipairs(line_metadata) do
        local row = padding_top + i - 1

        if meta.type == "header" then
            vim.api.nvim_buf_set_extmark(buf, ns_id, row, padding_left, {
                end_col = padding_left + #meta.text,
                hl_group = "Title",
            })
        elseif meta.type == "file" then
            local fname = vim.fn.fnamemodify(meta.data, ":t")
            local start_idx = meta.text:find(fname, 1, true)
            if start_idx then
                vim.api.nvim_buf_set_extmark(buf, ns_id, row, padding_left, {
                    end_col = padding_left + start_idx - 1,
                    hl_group = "NonText",
                })
                vim.api.nvim_buf_set_extmark(buf, ns_id, row, padding_left + start_idx - 1, {
                    end_col = padding_left + #meta.text,
                    hl_group = "Special",
                })
            end
            file_map[row + 1] = meta.data
            table.insert(valid_lines, row + 1)
        elseif meta.type == "footer" then
            local s = meta.data
            local curr = padding_left

            local p_len = #s.prefix
            vim.api.nvim_buf_set_extmark(buf, ns_id, row, curr, {
                end_col = curr + p_len,
                hl_group = "Comment",
            })
            curr = curr + p_len

            local s_len = #s.stats
            vim.api.nvim_buf_set_extmark(buf, ns_id, row, curr, {
                end_col = curr + s_len,
                hl_group = "Special",
            })
            curr = curr + s_len

            local m_len = #s.middle
            vim.api.nvim_buf_set_extmark(buf, ns_id, row, curr, {
                end_col = curr + m_len,
                hl_group = "Comment",
            })
            curr = curr + m_len

            vim.api.nvim_buf_set_extmark(buf, ns_id, row, curr, {
                end_col = curr + #s.time,
                hl_group = "Special",
            })
        end
    end

    local win = vim.api.nvim_get_current_win()
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false
    vim.wo[win].cursorline = true
    vim.wo[win].signcolumn = "no"
    vim.wo[win].fillchars = "eob: "

    local opts = { buffer = buf, silent = true, nowait = true }
    vim.keymap.set('n', '<CR>', function()
        local r = vim.api.nvim_win_get_cursor(0)[1]
        if file_map[r] then vim.cmd("edit " .. vim.fn.fnameescape(file_map[r])) end
    end, opts)
    vim.keymap.set('n', 'q', '<cmd>q<CR>', opts)

    if #valid_lines > 0 then
        local target_col = padding_left + 2
        pcall(vim.api.nvim_win_set_cursor, win, { valid_lines[1], target_col })
        last_cursor_row = valid_lines[1]
        lock_cursor(buf, target_col)
    end
end

function M.setup()
    if vim.fn.argc() == 0 then
        vim.api.nvim_create_autocmd("VimEnter", {
            group = DASH_AU_GROUP,
            callback = function()
                vim.schedule(function()
                    if vim.api.nvim_buf_get_name(0) == "" then M.draw() end
                end)
            end,
            once = true,
        })
    end
end

return M
