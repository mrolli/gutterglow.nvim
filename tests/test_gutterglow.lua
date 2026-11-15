local new_set = MiniTest.new_set
local eq = MiniTest.expect.equality

local child = MiniTest.new_child_neovim()

local T = new_set({
  hooks = {
    pre_case = function()
      child.restart({ '-u', 'tests/minimal_init.lua' })
    end,
    post_once = child.stop,
  },
})

local function setup(opts)
  child.lua('require("gutterglow").setup(...)', { opts or {} })
end

local function with_lualine()
  child.lua('vim.opt.runtimepath:prepend(vim.fn.getcwd() .. "/tests/fixtures/lualine")')
end

local function link()
  return child.api.nvim_get_hl(0, { name = 'CursorLineNr' }).link
end

local function hl(name)
  return child.api.nvim_get_hl(0, { name = name, link = false })
end

T['modes'] = new_set()

T['modes']['switch CursorLineNr link'] = function()
  setup()
  eq(link(), 'GutterglowNormal')
  child.type_keys('i')
  eq(link(), 'GutterglowInsert')
  child.type_keys('<Esc>v')
  eq(link(), 'GutterglowVisual')
  child.type_keys('<Esc>R')
  eq(link(), 'GutterglowReplace')
  child.type_keys('<Esc>:')
  eq(link(), 'GutterglowCommand')
  child.type_keys('<Esc>')
  eq(link(), 'GutterglowNormal')
end

T['modes']['change the rendered line number'] = function()
  setup({ modes = { insert = { fg = '#ff0000', bg = '#00ff00' } } })
  local normal = child.fn.screenattr(1, 1)
  child.type_keys('i')
  eq(child.fn.screenattr(1, 1) ~= normal, true)
  child.type_keys('<Esc>')
  eq(child.fn.screenattr(1, 1), normal)
end

T['config'] = new_set()

T['config']['uses configured colors'] = function()
  setup({ modes = { insert = { fg = '#123456', bg = '#654321' } } })
  local insert = hl('GutterglowInsert')
  eq({ insert.fg, insert.bg }, { 0x123456, 0x654321 })
end

T['config']['mode color replaces default'] = function()
  setup({ lualine = { enabled = false }, modes = { insert = { fg = '#123456' } } })
  local insert = hl('GutterglowInsert')
  eq({ insert.fg, insert.bg, insert.bold }, { 0x123456, nil, nil })
end

T['config']['copies highlight groups'] = function()
  child.api.nvim_set_hl(0, 'MyInsert', { fg = '#abcdef' })
  setup({ modes = { insert = 'MyInsert' } })
  eq(hl('GutterglowInsert').fg, 0xabcdef)
end

T['config']['defaults to Nvim palette'] = function()
  setup({ lualine = { enabled = false } })
  local insert = hl('GutterglowInsert')
  eq({ insert.fg, insert.bg, insert.bold }, { 460813, 11794112, true })
end

T['config']['CursorLineNr keeps the original'] = function()
  child.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#111111' })
  setup({ modes = { normal = 'CursorLineNr' } })
  eq(hl('GutterglowNormal').fg, 0x111111)
end

T['config']['rejects invalid options'] = function()
  eq(pcall(child.lua, 'require("gutterglow").setup({ lualine = { enabled = "yes" } })'), false)
end

T['lualine'] = new_set()

T['lualine']['takes precedence over config'] = function()
  with_lualine()
  setup({ modes = { insert = { fg = '#123456' } } })
  local insert = hl('GutterglowInsert')
  eq({ insert.fg, insert.bg }, { 3, 4 })
  local normal = hl('GutterglowNormal')
  eq({ normal.fg, normal.bg, normal.bold }, { 1, 2, true })
end

T['lualine']['select falls back to visual'] = function()
  with_lualine()
  setup()
  eq(hl('GutterglowSelect').bg, 6)
end

T['lualine']['missing mode falls back to normal'] = function()
  with_lualine()
  setup()
  eq(hl('GutterglowTerminal').bg, 2)
end

T['lualine']['can be disabled'] = function()
  with_lualine()
  setup({ lualine = { enabled = false }, modes = { insert = { fg = '#123456' } } })
  eq(hl('GutterglowInsert').fg, 0x123456)
end

T['lifecycle'] = new_set()

T['lifecycle']['ColorScheme reapplies'] = function()
  setup()
  child.cmd('colorscheme default')
  eq(link(), 'GutterglowNormal')
  eq(vim.tbl_isempty(hl('GutterglowInsert')), false)
end

T['lifecycle']['disable restores CursorLineNr'] = function()
  child.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#222222' })
  setup()
  child.lua('require("gutterglow").disable()')
  eq(link(), nil)
  eq(hl('CursorLineNr').fg, 0x222222)
  child.type_keys('i')
  eq(link(), nil)
end

T['lifecycle']['command toggles'] = function()
  setup()
  child.cmd('Gutterglow toggle')
  eq(link(), nil)
  child.cmd('Gutterglow toggle')
  eq(link(), 'GutterglowNormal')
end

return T
