-- Override Kickstart defaults here to keep init.lua close to upstream.
vim.schedule(function()
  vim.o.clipboard = ''
end)
