local M = {}

---@return table? theme
local function theme()
  local ok, lualine = pcall(require, 'lualine')
  if not ok then
    return nil
  end
  local t = lualine.get_config().options.theme
  if type(t) == 'table' then
    return t
  end
  local loaded, result = pcall(require('lualine.utils.loader').load_theme, t)
  return loaded and type(result) == 'table' and result or nil
end

--- Colors of lualine's mode indicator, or `nil` if unavailable.
---@param mode gutterglow.Mode
---@param section string
---@return vim.api.keyset.highlight?
function M.get(mode, section)
  local t = theme()
  if not t then
    return nil
  end
  -- lualine shows select mode with visual colors
  local colors = t[mode] or (mode == 'select' and t.visual) or t.normal
  local hl = type(colors) == 'table' and colors[section] or (t.normal or {})[section]
  if type(hl) ~= 'table' or not (hl.fg or hl.bg) then
    return nil
  end
  local gui = hl.gui or ''
  return {
    fg = hl.fg,
    bg = hl.bg,
    bold = gui:find('bold') ~= nil,
    italic = gui:find('italic') ~= nil,
  }
end

return M
