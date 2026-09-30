local items = {}
local order = {}

local bufnr
local winid
local render_pending = false

local function progress_key(client_id, token)
    return string.format(
        '%d:%s:%s',
        client_id,
        type(token),
        tostring(token)
    )
end

local function remove_item(key)
    if not items[key] then
        return
    end

    items[key] = nil

    for i, current in ipairs(order) do
        if current == key then
            table.remove(order, i)
            break
        end
    end
end

local function close_window()
    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_close(winid, true)
    end

    winid = nil

    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    bufnr = nil
end

local function render()
    local lines = {}
    local width = 1

    -- 保持原来的排列方式：
    -- 最早的任务在最下面，新的任务向上堆叠。
    for i = #order, 1, -1 do
        local item = items[order[i]]

        if item then
            lines[#lines + 1] = item.message
            width = math.max(
                width,
                vim.fn.strdisplaywidth(item.message)
            )
        end
    end

    if #lines == 0 then
        close_window()
        return
    end

    width = math.min(
        width,
        math.max(1, vim.o.columns - 2)
    )

    if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        bufnr = vim.api.nvim_create_buf(false, true)
    end

    vim.api.nvim_buf_set_lines(
        bufnr,
        0,
        -1,
        false,
        lines
    )

    -- 如果切换了 tab，把浮窗移动到当前 tab，
    -- 避免旧 tab 遗留无人管理的窗口。
    if
        winid
        and vim.api.nvim_win_is_valid(winid)
        and vim.api.nvim_win_get_tabpage(winid)
        ~= vim.api.nvim_get_current_tabpage()
    then
        vim.api.nvim_win_close(winid, true)
        winid = nil
    end

    local statusline_height =
        vim.o.laststatus == 0 and 0 or 1

    local row =
        vim.o.lines
        - vim.o.cmdheight
        - statusline_height

    local config = {
        relative = 'editor',
        anchor = 'SE',
        width = width,
        height = #lines,
        row = row,
        col = vim.o.columns,
    }

    if winid and vim.api.nvim_win_is_valid(winid) then
        vim.api.nvim_win_set_config(winid, config)
    else
        config.focusable = false
        config.style = 'minimal'
        config.noautocmd = true
        config.zindex = 30

        winid = vim.api.nvim_open_win(
            bufnr,
            false,
            config
        )

        vim.wo[winid].wrap = false
    end
end

local function schedule_render()
    if render_pending then
        return
    end

    render_pending = true

    vim.schedule(function()
        render_pending = false
        render()
    end)
end

local function format_message(client, value)
    local message = client.name

    if value.title and value.title ~= '' then
        message = message .. ' ' .. value.title
    end

    if value.message and value.message ~= '' then
        message = message .. ' ' .. value.message
    end

    if value.kind == 'end' then
        return message .. ' done'
    end

    if value.percentage ~= nil then
        message = string.format(
            '%s (%3d%%)',
            message,
            value.percentage
        )
    end

    return message
end

local group = vim.api.nvim_create_augroup(
    'LspProgress',
    { clear = true }
)

vim.api.nvim_create_autocmd('LspProgress', {
    group = group,

    callback = function(event)
        local client =
            vim.lsp.get_client_by_id(event.data.client_id)

        if not client then
            return
        end

        local params = event.data.params
        local value = params and params.value

        if
            type(value) ~= 'table'
            or (
                value.kind ~= 'begin'
                and value.kind ~= 'report'
                and value.kind ~= 'end'
            )
        then
            return
        end

        local key = progress_key(
            client.id,
            params.token
        )

        local item = items[key]

        if not item then
            item = {
                client_id = client.id,
                generation = 0,
            }

            items[key] = item
            order[#order + 1] = key
        end

        item.generation = item.generation + 1
        item.message = format_message(client, value)

        local generation = item.generation

        schedule_render()

        if value.kind == 'end' then
            vim.defer_fn(function()
                local current = items[key]

                -- 同一个 token 在 2 秒内又开始了新任务，
                -- 旧的延迟清理不能删除新的 progress。
                if
                    current
                    and current.generation == generation
                then
                    remove_item(key)
                    schedule_render()
                end
            end, 2000)
        end
    end,
})

vim.api.nvim_create_autocmd('LspDetach', {
    group = group,

    callback = function(event)
        local client_id = event.data.client_id
        local changed = false

        for key, item in pairs(items) do
            if item.client_id == client_id then
                items[key] = nil
                changed = true
            end
        end

        if not changed then
            return
        end

        local remaining = {}

        for _, key in ipairs(order) do
            if items[key] then
                remaining[#remaining + 1] = key
            end
        end

        order = remaining

        schedule_render()
    end,
})

vim.api.nvim_create_autocmd(
    {
        'VimResized',
        'TabEnter',
        'TermLeave',
    },
    {
        group = group,
        callback = schedule_render,
    }
)
