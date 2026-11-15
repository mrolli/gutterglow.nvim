# gutterglow.nvim

_Cursor line number mode indicator._

A small Neovim plugin that changes the color of your cursor's line number based on the current Vim mode.

gutterglow has [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) support [out of the box](#lualine-integration).

## Requirements

- Neovim >= 0.12
- `number`, `cursorline` and `termguicolors` set, with `cursorlineopt` including `number` (the default `both` works)

```lua
vim.o.number = true
vim.o.cursorline = true
vim.o.termguicolors = true
```

Run `:checkhealth gutterglow` to verify your setup.

## Setup

Nothing happens until `setup()` is called.

With the built-in package manager (`vim.pack`):

```lua
vim.pack.add({ 'https://github.com/mrolli/gutterglow.nvim' })
require('gutterglow').setup()
```

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'mrolli/gutterglow.nvim',
  event = 'VeryLazy',
  opts = {},
}
```

## Configuration

### Default configuration

```lua
require('gutterglow').setup({
  lualine = {
    -- Use lualine's mode colors when lualine is available
    enabled = true,
    -- lualine theme section to read the colors from
    section = 'a',
  },
  -- Colors used when lualine is unavailable or disabled, taken from
  -- Neovim's built-in palette.
  -- Each entry is either a highlight definition as accepted by
  -- `nvim_set_hl()`, or a highlight group name to copy from.
  -- 'CursorLineNr' keeps the colorscheme's original line number.
  modes = {
    normal = { fg = 'NvimDarkGrey1', bg = 'NvimLightBlue', bold = true },
    insert = { fg = 'NvimDarkGrey1', bg = 'NvimLightGreen', bold = true },
    visual = { fg = 'NvimDarkGrey1', bg = 'NvimLightMagenta', bold = true },
    select = { fg = 'NvimDarkGrey1', bg = 'NvimLightMagenta', bold = true },
    replace = { fg = 'NvimDarkGrey1', bg = 'NvimLightRed', bold = true },
    command = { fg = 'NvimDarkGrey1', bg = 'NvimLightYellow', bold = true },
    terminal = { fg = 'NvimDarkGrey1', bg = 'NvimLightCyan', bold = true },
  },
})
```

### Custom colors

Mode entries are not merged: a table or group name replaces the whole default for that mode, so give `fg`, `bg` and `bold` as needed.

```lua
require('gutterglow').setup({
  lualine = { enabled = false },
  modes = {
    normal = 'CursorLineNr', -- keep the colorscheme's line number
    insert = { fg = '#1e1e2e', bg = '#a6e3a1', bold = true },
    visual = 'Visual', -- copy an existing highlight group
  },
})
```

### Color priority

1. lualine mode colors, if lualine is available and `lualine.enabled = true`
2. `modes` from your configuration

### Modes

| Mode key   | Vim modes                       |
| ---------- | ------------------------------- |
| `normal`   | Normal, Operator-pending, `nt`  |
| `insert`   | Insert                          |
| `visual`   | Visual, Visual line, Visual block |
| `select`   | Select, Select line, Select block |
| `replace`  | Replace, Virtual replace        |
| `command`  | Command-line                    |
| `terminal` | Terminal                        |

### Commands and API

| Command               | Lua                                | Description                            |
| --------------------- | ---------------------------------- | -------------------------------------- |
| `:Gutterglow enable`  | `require('gutterglow').enable()`   | Enable                                 |
| `:Gutterglow disable` | `require('gutterglow').disable()`  | Disable and restore `CursorLineNr`     |
| `:Gutterglow toggle`  | `require('gutterglow').toggle()`   | Toggle                                 |
| `:Gutterglow refresh` | `require('gutterglow').refresh()`  | Re-read colors (lualine or config)     |

### Highlight groups

gutterglow defines one highlight group per mode and links `CursorLineNr` to the group of the current mode:

`GutterglowNormal`, `GutterglowInsert`, `GutterglowVisual`, `GutterglowSelect`, `GutterglowReplace`, `GutterglowCommand`, `GutterglowTerminal`

The groups are recreated on `ColorScheme`. To change colors, use the `modes` option rather than redefining the groups.

## Lualine integration

gutterglow has built-in support for [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim), meaning that if it detects lualine.nvim in your setup it will use the same colors for each mode as lualine.nvim uses. Both foreground and background of lualine's mode indicator (section `a` by default) are copied, including bold and italic. To disable this feature, you can set `lualine.enabled = false` in your [gutterglow configuration](#default-configuration).

Notes:

- Select mode uses lualine's `visual` colors, just like lualine does; modes missing from the theme fall back to `normal`.
- If your mode component lives in another section, set `lualine.section`, e.g. `'b'`.
- Colors are read on setup, `VimEnter` and `ColorScheme`. If you change lualine's theme at runtime, run `:Gutterglow refresh`.

## Issues with other plugins

- Plugins or colorschemes that set `CursorLineNr` after gutterglow overwrite its link until the next mode change.
- Plugins that disable `cursorline` or `number` for some windows (e.g. dashboards, file explorers) hide the effect there; this is expected.
- If the line number does not change at all, check `:checkhealth gutterglow`.

## Development

```sh
make test   # run tests headless (mini.test is cloned into deps/)
make fmt    # format with stylua
make lint   # check formatting
```

- See [AGENTS.md](AGENTS.md) for specification and conventions.
- `doc/gutterglow.txt` is generated from this README by CI ([panvimdoc](https://github.com/kdheepak/panvimdoc)); do not edit it by hand.
