-- gitsigns configuration
require('gitsigns').setup({
	signs = {
		add          = { text = '┃' },
		change       = { text = '┃' },
		delete       = { text = '_' },
		topdelete    = { text = '‾' },
		changedelete = { text = '~' },
		untracked    = { text = '┆' },
	},
	signcolumn = true,  -- toggle with `:Gitsigns toggle_signs`
	numhl      = false, -- toggle with `:Gitsigns toggle_numhl`
	linehl     = false, -- toggle with `:Gitsigns toggle_linehl`
	word_diff  = false, -- toggle with `:Gitsigns toggle_word_diff`
	watch_gitdir = {
		follow_files = true
	},
	attach_to_untracked = true,
	current_line_blame = false, -- toggle with `:Gitsigns toggle_current_line_blame`
	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
		delay = 1000,
		ignore_whitespace = false,
	},
	sign_priority = 10,
	update_debounce = 100,
	status_formatter = nil, -- use default
	max_file_length = 40000, -- disable if file is longer than this
	preview_config = {
		-- options passed to nvim_open_win
		border = 'single',
		style = 'minimal',
		relative = 'cursor',
		row = 0,
		col = 1
	},
})

-- gitsigns keymaps
vim.keymap.set('n', '<leader>gp', '<cmd>Gitsigns preview_hunk<CR>')
vim.keymap.set('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
vim.keymap.set('n', ']c', '<cmd>Gitsigns next_hunk<CR>')
vim.keymap.set('n', '[c', '<cmd>Gitsigns prev_hunk<CR>')

-- debug function
function _G.debug_gitsigns()
	print("Gitsigns loaded:", vim.fn.exists(':Gitsigns'))
	print("Current file:", vim.fn.expand('%:p'))
	print("In git repo:", vim.fn.system('git rev-parse --is-inside-work-tree 2>nul'):match('true'))
	print("Sign column enabled:", vim.opt.signcolumn:get())
	vim.cmd('Gitsigns debug_messages')
end
