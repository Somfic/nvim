vim.pack.add({
	{ src = 'https://github.com/folke/which-key.nvim' },
})

vim.g.mapleader = ' '
require('which-key').setup({
	preset = 'helix',
})

-- w and s to move a line up and down
vim.keymap.set({ 'n', 'v' }, 'w', 'k', { desc = 'Line up' })
vim.keymap.set({ 'n', 'v' }, 's', 'j', { desc = 'Line down' })

-- shift w and s to jump between code blocks
vim.keymap.set({ 'n', 'v' }, 'W', '{', { desc = 'Jump to previous block' })
vim.keymap.set({ 'n', 'v' }, 'S', '}', { desc = 'Jump to next block' })

-- a and d to move left and right
vim.keymap.set({ 'n', 'v' }, 'a', 'h', { desc = 'Move left' })
vim.keymap.set({ 'n', 'v' }, 'd', 'l', { desc = 'Move right' })

-- shift a and d to move a word left and right
vim.keymap.set({ 'n', 'v' }, 'A', 'b', { desc = 'Word backward' })
vim.keymap.set({ 'n', 'v' }, 'D', 'w', { desc = 'Word forward' })

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
