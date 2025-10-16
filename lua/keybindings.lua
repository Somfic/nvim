vim.pack.add({
	{ src = 'https://github.com/folke/which-key.nvim' },
})

vim.g.mapleader = ' '
require('which-key').setup({
	preset = 'helix',
})

-- line navigation
vim.keymap.set({ 'n', 'v' }, 'w', 'k', { desc = 'Line up' })
vim.keymap.set({ 'n', 'v' }, 's', 'j', { desc = 'Line down' })
vim.keymap.set({ 'n', 'v' }, 'A', '^', { desc = 'Beginning of line' })
vim.keymap.set({ 'n', 'v' }, 'D', '$', { desc = 'End of line' })

-- block navigation
vim.keymap.set({ 'n', 'v' }, 'W', '{', { desc = 'Jump to previous block' })
vim.keymap.set({ 'n', 'v' }, 'S', '}', { desc = 'Jump to next block' })

-- character navigation
vim.keymap.set({ 'n', 'v' }, 'a', 'h', { desc = 'Move left' })
vim.keymap.set({ 'n', 'v' }, 'd', 'l', { desc = 'Move right' })

-- word navigation
vim.keymap.set({ 'n', 'v' }, 'q', 'b', { desc = 'Word backward' })
vim.keymap.set({ 'n', 'v' }, 'e', 'w', { desc = 'Word forward' })

-- clipboard
vim.keymap.set({ 'n', 'v' }, 'x', 'dd', { desc = 'Cut' })
vim.keymap.set({ 'n', 'v' }, 'p', 'p', { desc = 'Paste' })

-- moving lines
vim.keymap.set('i', '<M-w>', '<Esc>:m .-2<CR>==gi', { desc = 'Move line up', noremap = true, silent = true })
vim.keymap.set('n', '<M-w>', ':m .-2<CR>==', { desc = 'Move line up', noremap = true, silent = true })
vim.keymap.set('n', '<M-s>', ':m .+1<CR>==', { desc = 'Move line down', noremap = true, silent = true })
vim.keymap.set('i', '<M-s>', '<Esc>:m .+1<CR>==gi', { desc = 'Move line down', noremap = true, silent = true })
vim.keymap.set('v', '<M-w>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up', noremap = true, silent = true })
vim.keymap.set('v', '<M-s>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down', noremap = true, silent = true })

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
