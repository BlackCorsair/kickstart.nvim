vim.keymap.set('n', 'P', ':pu<CR>', { desc = 'Insert copy in a new line' })
vim.keymap.set('n', '<leader>=t', ":!column -t -s ' | ' -o ' | '", { desc = 'format a markdown table' })

vim.keymap.set('n', '<leader>so', function()
  local vault = vim.fn.expand '~/Documents/obsidian'
  vim.cmd('cd ' .. vim.fn.fnameescape(vault))
  require('oil').open(vault)
end, { desc = 'Open Obsidian vault in Oil' })
