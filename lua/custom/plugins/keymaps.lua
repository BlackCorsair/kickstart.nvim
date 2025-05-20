return {
  vim.keymap.set('n', 'P', ':pu<CR>', { desc = 'Insert copy in a new line' }),
  vim.keymap.set('n', '<leader>=t', "!column -t -s ' | ' -o ' | '", { desc = 'format a markdown table' }),
}
