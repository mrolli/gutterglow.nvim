local M = {}

---@alias gutterglow.Mode 'normal'|'insert'|'visual'|'select'|'replace'|'command'|'terminal'

--- Highlight group name to copy from, or a highlight definition (see `:h nvim_set_hl()`).
---@alias gutterglow.Color string|vim.api.keyset.highlight

---@class gutterglow.LualineConfig
---@field enabled? boolean Use lualine's mode colors if lualine is available
---@field section? 'a'|'b'|'c'|'x'|'y'|'z' lualine theme section to read colors from

---@class gutterglow.Config
---@field lualine? gutterglow.LualineConfig
---@field modes? table<gutterglow.Mode, gutterglow.Color> `'CursorLineNr'` keeps the original

---@type gutterglow.Mode[]
M.modes = { 'normal', 'insert', 'visual', 'select', 'replace', 'command', 'terminal' }

---@type gutterglow.Config
M.defaults = {
  lualine = {
    enabled = true,
    section = 'a',
  },
  modes = {
    normal = { fg = 'NvimDarkGrey1', bg = 'NvimLightBlue', bold = true },
    insert = { fg = 'NvimDarkGrey1', bg = 'NvimLightGreen', bold = true },
    visual = { fg = 'NvimDarkGrey1', bg = 'NvimLightMagenta', bold = true },
    select = { fg = 'NvimDarkGrey1', bg = 'NvimLightMagenta', bold = true },
    replace = { fg = 'NvimDarkGrey1', bg = 'NvimLightRed', bold = true },
    command = { fg = 'NvimDarkGrey1', bg = 'NvimLightYellow', bold = true },
    terminal = { fg = 'NvimDarkGrey1', bg = 'NvimLightCyan', bold = true },
  },
}

---@param opts? gutterglow.Config
---@return gutterglow.Config
function M.merge(opts)
  opts = opts or {}
  local cfg = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts)
  -- a mode's color replaces the default as a whole instead of being merged
  for mode, color in pairs(opts.modes or {}) do
    cfg.modes[mode] = color
  end
  vim.validate('lualine', cfg.lualine, 'table')
  vim.validate('lualine.enabled', cfg.lualine.enabled, 'boolean')
  vim.validate('lualine.section', cfg.lualine.section, 'string')
  vim.validate('modes', cfg.modes, 'table')
  for _, mode in ipairs(M.modes) do
    vim.validate('modes.' .. mode, cfg.modes[mode], { 'string', 'table' })
  end
  return cfg
end

return M
