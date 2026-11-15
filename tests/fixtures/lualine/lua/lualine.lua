-- Minimal lualine stub exposing a table theme.
return {
  get_config = function()
    return {
      options = {
        theme = {
          normal = { a = { fg = '#000001', bg = '#000002', gui = 'bold' } },
          insert = { a = { fg = '#000003', bg = '#000004' } },
          visual = { a = { fg = '#000005', bg = '#000006' } },
        },
      },
    }
  end,
}
