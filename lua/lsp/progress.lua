local items = {}
local order = {}

local bufnr
local winid
local render_pending = false
local sequence = 0

local function progress_key(client_id, token)
    return string.format(
        '%d:%s:%s',
        client_id,
        type(token),
        tostring(token)
    )
end

local function display_key(item)
    if item.title and item.title ~= '' then
        return string.format(
            '%d:%s',
            item.client_id,
            item.title
        )
    end

    return item.key
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
        vim.api.nvim_buf_delete(
            bufnr,
            { force = true }
        )
    end

    bufnr = nil
end

local function visible_items()
    local groups = {}

    for _, key in ipairs(order) do
        local item = items[key]

        if item then
            local identity = display_key(item)
            local current = groups[identity]

            if not current then
                groups[identity] = item
            elseif current.done and not item.done then
                groups[identity] = item
            elseif current.done == item.done
                and item.sequence > current.sequence
            then
                groups[identity] = item
            end
        end
    end

    local result = {}

    for _, item in pairs(groups) do
        result[#result + 1] = item
    end

    table.sort(result, function(a, b)
        return a.sequence > b.sequence
    end)

    return result
end

local function render()
    local visible = visible_items()
    local lines = {}
    local width = 1

    for _, item in ipairs(visible) do
        lines[#lines + 1] = item.message

        width = math.max(
            width,
            vim.fn.strdisplaywidth(item.message)
        )
    end

    if #lines == 0 then
        close_window()
        return
    end

    width = math.min(
        width,
        math.max(1, vim.o.columns - 2)
    )

    if
        not bufnr
        or not vim.api.nvim_buf_is_valid(bufnr)
    then
        bufnr = vim.api.nvim_create_buf(
            false,
            true
        )
    end

    vim.api.nvim_buf_set_lines(
        bufnr,
        0,
        -1,
        false,
        lines
    )

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

    if
        winid
        and vim.api.nvim_win_is_valid(winid)
    then
        vim.api.nvim_win_set_config(
            winid,
            config
        )
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

vim.api.nvim_create_autocmd(
    'LspProgress',
    {
        group = group,

        callback = function(event)
            local client =
                vim.lsp.get_client_by_id(
                    event.data.client_id
                )

            if not client then
                return
            end

            local params = event.data.params
            local value =
                params and params.value

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
                    key = key,
                    client_id = client.id,
                    generation = 0,
                }

                items[key] = item
                order[#order + 1] = key
            end

            sequence = sequence + 1

            item.generation =
                item.generation + 1
            item.sequence = sequence
            item.title = value.title
            item.done = value.kind == 'end'
            item.message =
                format_message(client, value)

            local generation =
                item.generation

            schedule_render()

            if item.done then
                vim.defer_fn(function()
                    local current = items[key]

                    if
                        current
                        and current.generation
                        == generation
                    then
                        remove_item(key)
                        schedule_render()
                    end
                end, 2000)
            end
        end,
    }
)

vim.api.nvim_create_autocmd(
    'LspDetach',
    {
        group = group,

        callback = function(event)
            local client =
                vim.lsp.get_client_by_id(
                    event.data.client_id
                )

            if not client then
                return
            end

            if
                vim.tbl_count(
                    client.attached_buffers
                ) > 1
            then
                return
            end

            local changed = false

            for key, item in pairs(items) do
                if
                    item.client_id == client.id
                then
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
                    remaining[#remaining + 1] =
                        key
                end
            end

            order = remaining

            schedule_render()
        end,
    }
)

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
