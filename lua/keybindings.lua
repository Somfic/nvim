vim.pack.add({
	{ src = 'https://github.com/folke/which-key.nvim' },
})

vim.g.mapleader = ' '
require('which-key').setup({
	preset = 'helix',
})
