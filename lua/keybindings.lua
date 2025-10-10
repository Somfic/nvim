vim.pack.add({
	{ src = 'https://github.com/folke/which-key.nvim' },
})

vim.g.mapleader = ' '
require('which-key').setup({
	preset = 'helix',
})

-- WASD navigation
vim.keymap.set({ 'n', 'v' }, 'w', 'k', { desc = 'Move up' })
vim.keymap.set({ 'n', 'v' }, 's', 'j', { desc = 'Move down' })
vim.keymap.set({ 'n', 'v' }, 'a', 'b', { desc = 'Word backward' })
vim.keymap.set({ 'n', 'v' }, 'd', 'w', { desc = 'Word forward' })
vim.keymap.set({ 'n', 'v' }, 'A', 'h', { desc = 'Character left' })
vim.keymap.set({ 'n', 'v' }, 'D', 'l', { desc = 'Character right' })
vim.keymap.set({ 'n', 'v' }, 'W', '{', { desc = 'Previous code block' })
vim.keymap.set({ 'n', 'v' }, 'S', '}', { desc = 'Next code block' })
vim.keymap.set({ 'n', 'v' }, '<M-a>', '^', { desc = 'Line start (non-blank)' })
vim.keymap.set({ 'n', 'v' }, '<M-d>', '$', { desc = 'Line end' })

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
