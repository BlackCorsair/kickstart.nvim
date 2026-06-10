vim.pack.add {
  'https://github.com/echasnovski/mini.icons',
  'https://github.com/stevearc/oil.nvim',
}

require('mini.icons').setup {}
require('oil').setup {
  view_options = {
    show_hidden = true,
  },
}

vim.keymap.set('n', '<leader>o', '<cmd>Oil<CR>', { desc = '[O]pen Oil' })
