vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.getcwd() .. '/deps/mini.nvim')

vim.o.number = true
vim.o.cursorline = true
vim.o.termguicolors = true

if #vim.api.nvim_list_uis() == 0 then
  require('mini.test').setup()
end
