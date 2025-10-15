require('which-key').add({
	{ '<leader>l', group = 'lsp' },
	{
		'<leader>ld',
		'<cmd>Telescope lsp_definitions<CR>',
		desc = 'definition',
		mode = 'n'
	},
	{
		'<leader>lr',
		'<cmd>Telescope lsp_references<CR>',
		desc = 'references',
		mode = 'n'
	},
})
