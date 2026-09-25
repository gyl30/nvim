local M = {}

local state_file = vim.fn.stdpath("state") .. "/novel.json"

local reader = {
  buf = nil,
  win = nil,
  path = nil,
  chapters = {},
  height = 2,
}

local function is_open()
  return reader.win ~= nil and vim.api.nvim_win_is_valid(reader.win)
end

local function read_state()
  if vim.fn.filereadable(state_file) == 0 then
    return { positions = {} }
  end

  local ok, state = pcall(vim.json.decode, table.concat(vim.fn.readfile(state_file), "\n"))
  if not ok or type(state) ~= "table" then
    return { positions = {} }
  end

  state.positions = type(state.positions) == "table" and state.positions or {}
  return state
end

local function write_state(state)
  vim.fn.writefile({ vim.json.encode(state) }, state_file)
end

local function save_position()
  if not is_open() or not reader.path then
    return
  end

  local state = read_state()
  state.last_file = reader.path
  state.positions[reader.path] = vim.api.nvim_win_call(reader.win, function()
    return vim.fn.winsaveview()
  end)
  write_state(state)
end

local function window_config()
  local columns = vim.o.columns
  local lines = math.max(1, vim.o.lines - vim.o.cmdheight)
  local width = math.min(math.max(40, math.floor(columns * 0.42)), math.max(1, columns - 4))
  local height = math.min(reader.height, math.max(1, lines - 1))

  return {
    relative = "editor",
    row = math.max(0, lines - height - 1),
    col = math.max(0, columns - width - 1),
    width = width,
    height = height,
    style = "minimal",
    focusable = false,
    zindex = 40,
  }
end

local function parse_chapters(lines)
  local chapters = {}
  local pattern = vim.regex([[第[0-9一二三四五六七八九十百千万两]\+章]])

  for line_number, line in ipairs(lines) do
    if pattern:match_str(line) then
      chapters[#chapters + 1] = {
        line = line_number,
        title = vim.trim(line),
      }
    end
  end

  if #chapters == 0 then
    chapters[1] = { line = 1, title = "全文" }
  end

  return chapters
end

local function scroll(keys)
  if not is_open() then
    return
  end

  vim.api.nvim_win_call(reader.win, function()
    local termcodes = vim.api.nvim_replace_termcodes(keys, true, false, true)
    vim.cmd("normal! " .. termcodes)
  end)
end

local function jump_to(line_number)
  if not is_open() then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(reader.buf)
  local target = math.max(1, math.min(line_count, line_number))
  vim.api.nvim_win_set_cursor(reader.win, { target, 0 })
  vim.api.nvim_win_call(reader.win, function()
    vim.cmd("normal! zt")
  end)
end

function M.close()
  if not is_open() then
    return
  end

  save_position()
  vim.api.nvim_win_close(reader.win, true)
  reader.buf = nil
  reader.win = nil
  reader.path = nil
  reader.chapters = {}
end

function M.open(path, height)
  if is_open() then
    M.close()
  end

  reader.height = height or 2

  local state = read_state()
  path = path ~= "" and path or state.last_file
  if not path then
    vim.notify("novel path is required", vim.log.levels.ERROR)
    return
  end

  path = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  if vim.fn.filereadable(path) == 0 then
    vim.notify("novel file is not readable: " .. path, vim.log.levels.ERROR)
    return
  end

  local lines = vim.fn.readfile(path)
  if #lines == 0 then
    lines = { "" }
  end

  reader.path = path
  reader.chapters = parse_chapters(lines)
  reader.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(reader.buf, 0, -1, false, lines)
  vim.bo[reader.buf].modifiable = false
  vim.bo[reader.buf].bufhidden = "wipe"
  vim.bo[reader.buf].filetype = "text"

  reader.win = vim.api.nvim_open_win(reader.buf, false, window_config())
  vim.wo[reader.win].wrap = true
  vim.wo[reader.win].linebreak = true
  vim.wo[reader.win].smoothscroll = true
  vim.wo[reader.win].number = false
  vim.wo[reader.win].relativenumber = false
  vim.wo[reader.win].signcolumn = "no"
  vim.wo[reader.win].foldcolumn = "0"
  vim.wo[reader.win].cursorline = false
  vim.wo[reader.win].winhighlight = "Normal:Comment,NormalFloat:Comment"

  local saved = state.positions[path]
  if type(saved) == "table" then
    vim.api.nvim_win_call(reader.win, function()
      vim.fn.winrestview(saved)
    end)
  end
end

function M.chapters()
  if not is_open() then
    return
  end

  local entries = {}
  for _, chapter in ipairs(reader.chapters) do
    entries[#entries + 1] = string.format("%8d  %s", chapter.line, chapter.title)
  end

  require("fzf-lua").fzf_exec(entries, {
    prompt = "Chapters> ",
    previewer = false,
    actions = {
      default = function(selected)
        if not selected or not selected[1] then
          return
        end

        local line_number = tonumber(selected[1]:match("^%s*(%d+)"))
        if line_number then
          jump_to(line_number)
        end
      end,
    },
  })
end

function M.resize()
  if is_open() then
    vim.api.nvim_win_set_config(reader.win, window_config())
  end
end

function M.setup()
  vim.api.nvim_create_user_command("Novel", function(opts)
    local path = opts.fargs[1] or ""
    local height_arg = opts.fargs[2]

    if #opts.fargs == 1 and tonumber(opts.fargs[1]) then
      path = ""
      height_arg = opts.fargs[1]
    end

    if #opts.fargs > 2 then
      vim.notify("usage: Novel [path] [height]", vim.log.levels.ERROR)
      return
    end

    local height = tonumber(height_arg)
    if height_arg and not height then
      vim.notify("novel height must be a positive integer", vim.log.levels.ERROR)
      return
    end
    height = height or 2
    if height < 1 or height % 1 ~= 0 then
      vim.notify("novel height must be a positive integer", vim.log.levels.ERROR)
      return
    end

    if #opts.fargs == 1 and height_arg and is_open() then
      reader.height = height
      M.resize()
      return
    end

    M.open(path, height)
  end, {
    nargs = "*",
    complete = "file",
  })

  vim.keymap.set({ "n", "i" }, "<M-i>", function()
    scroll("<C-y>")
  end, { silent = true, desc = "Novel up" })

  vim.keymap.set({ "n", "i" }, "<M-k>", function()
    scroll("<C-e>")
  end, { silent = true, desc = "Novel down" })

  vim.keymap.set({ "n", "i" }, "<M-s>", M.chapters, { silent = true, desc = "Novel chapters" })
  vim.keymap.set({ "n", "i" }, "<M-q>", M.close, { silent = true, desc = "Novel close" })

  local group = vim.api.nvim_create_augroup("NovelReader", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = M.resize,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = save_position,
  })
end

return M
