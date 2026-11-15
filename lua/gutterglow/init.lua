local api = vim.api
local config = require('gutterglow.config')

local M = {}

---@type gutterglow.Config?
M.config = nil

---@type integer?
local augroup = nil

--- `CursorLineNr` as defined by the colorscheme, before gutterglow took over.
---@type vim.api.keyset.highlight
local original = {}

---@type table<string, gutterglow.Mode>
local mode_map = {
  n = 'normal',
  i = 'insert',
  v = 'visual',
  V = 'visual',
  ['\22'] = 'visual',
  s = 'select',
  S = 'select',
  ['\19'] = 'select',
  R = 'replace',
  c = 'command',
  t = 'terminal',
}

---@param mode gutterglow.Mode
---@return string
local function group_name(mode)
  return 'Gutterglow' .. mode:sub(1, 1):upper() .. mode:sub(2)
end

---@param name string
---@return vim.api.keyset.highlight
local function get_hl(name)
  return api.nvim_get_hl(0, { name = name, link = false }) --[[@as vim.api.keyset.highlight]]
end

local function snapshot()
  local link = api.nvim_get_hl(0, { name = 'CursorLineNr' }).link
  if not (link and link:find('^Gutterglow')) then
    original = get_hl('CursorLineNr')
  end
end

---@param mode gutterglow.Mode
---@return vim.api.keyset.highlight
local function resolve(mode)
  local cfg = assert(M.config)
  if cfg.lualine.enabled then
    local hl = require('gutterglow.lualine').get(mode, cfg.lualine.section)
    if hl then
      return hl
    end
  end
  local color = cfg.modes[mode]
  if color == 'CursorLineNr' then
    return original
  end
  return type(color) == 'string' and get_hl(color) or color
end

local function apply()
  local m = api.nvim_get_mode().mode
  local mode = m == 'nt' and 'normal' or mode_map[m:sub(1, 1)] or 'normal'
  api.nvim_set_hl(0, 'CursorLineNr', { link = group_name(mode) })
end

--- Re-read colors (lualine or config) and re-apply them.
function M.refresh()
  if not augroup then
    return
  end
  for _, mode in ipairs(config.modes) do
    api.nvim_set_hl(0, group_name(mode), resolve(mode))
  end
  apply()
end

function M.enable()
  if augroup then
    return
  end
  augroup = api.nvim_create_augroup('Gutterglow', { clear = true })
  api.nvim_create_autocmd('ModeChanged', { group = augroup, callback = apply })
  api.nvim_create_autocmd('ColorScheme', {
    group = augroup,
    callback = function()
      snapshot()
      M.refresh()
    end,
  })
  if vim.v.vim_did_enter == 0 then
    -- lualine may be configured after us
    api.nvim_create_autocmd('VimEnter', { group = augroup, once = true, callback = M.refresh })
  end
  snapshot()
  M.refresh()
end

function M.disable()
  if not augroup then
    return
  end
  api.nvim_del_augroup_by_id(augroup)
  augroup = nil
  api.nvim_set_hl(0, 'CursorLineNr', original)
end

function M.toggle()
  if augroup then
    M.disable()
  else
    M.enable()
  end
end

---@param opts? gutterglow.Config
function M.setup(opts)
  M.config = config.merge(opts)
  api.nvim_create_user_command('Gutterglow', function(args)
    M[args.fargs[1]]()
  end, {
    nargs = 1,
    desc = 'Gutterglow: enable, disable, toggle or refresh',
    complete = function()
      return { 'enable', 'disable', 'toggle', 'refresh' }
    end,
  })
  M.disable()
  M.enable()
end

return M
