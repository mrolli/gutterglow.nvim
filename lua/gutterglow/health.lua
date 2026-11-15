local M = {}

function M.check()
  local health = vim.health
  health.start('gutterglow')

  if vim.fn.has('nvim-0.12') == 0 then
    health.error('Neovim >= 0.12 required')
  end

  for _, opt in ipairs({ 'number', 'cursorline', 'termguicolors' }) do
    if vim.go[opt] then
      health.ok(("'%s' is set"):format(opt))
    else
      health.warn(
        ("'%s' is not set"):format(opt),
        ('Add `vim.o.%s = true` to your config'):format(opt)
      )
    end
  end

  local clo = vim.go.cursorlineopt
  if clo:find('number') or clo:find('both') then
    health.ok(("'cursorlineopt' is '%s'"):format(clo))
  else
    health.warn(("'cursorlineopt' is '%s'"):format(clo), "Include 'number' or 'both'")
  end

  local gutterglow = package.loaded.gutterglow
  if not (gutterglow and gutterglow.config) then
    health.warn('setup() has not been called')
    return
  end

  local has_lualine = pcall(require, 'lualine')
  if not gutterglow.config.lualine.enabled then
    health.info('lualine integration disabled, using configured colors')
  elseif has_lualine then
    health.ok('lualine detected, using its mode colors')
  else
    health.info('lualine not found, using configured colors')
  end
end

return M
