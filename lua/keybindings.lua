vim.pack.add({
	{ src = 'https://github.com/folke/which-key.nvim' },
})

vim.g.mapleader = ' '
require('which-key').setup({
	preset = 'helix',
})

-- Global completion trigger 
vim.keymap.set('i', '<C-Space>', function()
	-- Try to trigger nvim-cmp completion first
	local cmp = require('cmp')
	if cmp.visible() then
		cmp.select_next_item()
	else
		cmp.complete()
	end
end, { desc = 'Trigger completion' })
