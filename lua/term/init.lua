local api = vim.api
local M = {}

-- Store terminal information
vim.g.term_list = {}

-- Position data for different terminal layouts
local pos_data = {
  sp = { resize = "height", area = "lines" },
  ["bo sp"] = { resize = "height", area = "lines" },
}

-- Default configuration
local config = {
  float = {
    border = "rounded",
    width = 0.8,
    height = 0.8,
    row = 0.1,
    col = 0.1,
  },
  sizes = {
    sp = 0.3,
    ["bo sp"] = 0.3,
  },
  winopts = {
    number = false,
    relativenumber = false,
    cursorline = false,
    signcolumn = "no",
    winfixheight = true,
  },
}

-- Utility functions
local function save_term_info(index, val)
  local terms_list = vim.g.term_list
  terms_list[tostring(index)] = val
  vim.g.term_list = terms_list
end

local function opts_to_id(id)
  for _, opts in pairs(vim.g.term_list) do
    if opts.id == id then
      return opts
    end
  end
end

local function create_float(buffer, float_opts)
  local opts = vim.tbl_deep_extend("force", config.float, float_opts or {})

  opts.width = math.ceil(opts.width * vim.o.columns)
  opts.height = math.ceil(opts.height * vim.o.lines)
  opts.row = math.ceil(opts.row * vim.o.lines)
  opts.col = math.ceil(opts.col * vim.o.columns)

  vim.api.nvim_open_win(buffer, true, {
    relative = "editor",
    border = opts.border,
    width = opts.width,
    height = opts.height,
    row = opts.row,
    col = opts.col,
    style = "minimal",
  })
end

local function format_cmd(cmd)
  return type(cmd) == "string" and cmd or cmd()
end

-- Display function
M.display = function(opts)
  if opts.pos == "float" then
    create_float(opts.buf, opts.float_opts)
  else
    -- Ensure bottom terminal appears below statusline
    if opts.pos:match("bo") then
      vim.opt.cmdheight = 0  -- Minimize command height if possible
      vim.cmd("keepalt " .. opts.pos)
      vim.cmd("wincmd J")  -- Force window to bottom
    else
      vim.cmd(opts.pos)
    end
  end

  local win = api.nvim_get_current_win()
  opts.win = win

  vim.bo[opts.buf].buflisted = false
  
  -- Enter insert mode when focusing terminal
  vim.cmd("startinsert")
  
  -- Auto-enter insert mode when entering terminal window
  local group = vim.api.nvim_create_augroup("TerminalInsert", { clear = true })
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
      if vim.bo.buftype == "terminal" then
        vim.cmd("startinsert")
      end
    end,
    group = group
  })

  -- Resize non-floating windows
  if opts.pos ~= "float" then
    local pos_type = pos_data[opts.pos]
    local size = opts.size and opts.size or config.sizes[opts.pos]
    local new_size = vim.o[pos_type.area] * size
    api["nvim_win_set_" .. pos_type.resize](0, math.floor(new_size))
  end

  api.nvim_win_set_buf(win, opts.buf)

  local winopts = vim.tbl_deep_extend("force", config.winopts, opts.winopts or {})
  for k, v in pairs(winopts) do
    vim.wo[win][k] = v
  end

  save_term_info(opts.buf, opts)
end

-- Create new terminal
local function create(opts)
  local buf_exists = opts.buf
  opts.buf = opts.buf or vim.api.nvim_create_buf(false, true)

  local shell = vim.o.shell
  local cmd = shell

  if opts.cmd and opts.buf then
    cmd = { shell, "-c", format_cmd(opts.cmd) .. "; " .. shell }
  else
    cmd = { shell }
  end

  M.display(opts)
  save_term_info(opts.buf, opts)

  if not buf_exists then
    vim.fn.termopen(cmd, opts.termopen_opts or { detach = false })
  end
end

-- User API
M.new = function(opts)
  create(opts)
end

M.toggle = function(opts)
  local x = opts_to_id(opts.id)
  opts.buf = x and x.buf or nil

  if (x == nil or not api.nvim_buf_is_valid(x.buf)) or vim.fn.bufwinid(x.buf) == -1 then
    create(opts)
  else
    api.nvim_win_close(x.win, true)
  end
end

M.runner = function(opts)
  local x = opts_to_id(opts.id)
  local clear_cmd = opts.clear_cmd or "clear; "
  opts.buf = x and x.buf or nil

  if x == nil then
    create(opts)
  else
    if vim.fn.bufwinid(x.buf) == -1 then
      M.display(opts)
    end

    local cmd = format_cmd(opts.cmd)
    local job_id = vim.b[x.buf].terminal_job_id
    vim.api.nvim_chan_send(job_id, clear_cmd .. cmd .. " \n")
  end
end

-- Cleanup on terminal close
api.nvim_create_autocmd("TermClose", {
  callback = function(args)
    save_term_info(args.buf, nil)
  end,
})

return M