-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Iterate over all Lua files in the plugins directory and load them.
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')

---@param dir string
---@param prefix string
---@param modules string[]
local function collect_modules(dir, prefix, modules)
  for entry, type in vim.fs.dir(dir) do
    if type == 'directory' then
      collect_modules(vim.fs.joinpath(dir, entry), prefix .. entry .. '.', modules)
    elseif type == 'file' and entry:match '%.lua$' and entry ~= 'init.lua' then
      modules[#modules + 1] = prefix .. entry:gsub('%.lua$', '')
    end
  end
end

local modules = {}
collect_modules(plugins_dir, '', modules)
table.sort(modules)

for _, module in ipairs(modules) do
  require('custom.plugins.' .. module)
end
