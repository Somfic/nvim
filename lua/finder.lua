vim.pack.add({
	{ src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
})

require('telescope').setup({
	extensions = {
		['ui-select'] = {
			require('telescope.themes').get_dropdown {
				previewer = true,
				layout_config = {
					width = 0.8,
					height = 0.8,
				}
			}
		}
	}
})
require('telescope').load_extension('ui-select')

require('which-key').add({
	{ '<leader>f', group = 'find' },
	-- find files (git)
	{
		'<leader>ff',
		'<cmd>Telescope git_files<CR>',
		desc = 'files',
		mode = 'n',
		cond = function()
			return vim
			    .fn.isdirectory('.git') == 1
		end
	},
	-- find files (non-git)
	{
		'<leader>ff',
		'<cmd>Telescope find_files<CR>',
		desc = 'files',
		mode = 'n',
		cond = function()
			return vim
			    .fn.isdirectory('.git') == 0
		end
	},
	-- grep in current buffer
	{
		'<leader>fc',
		'<cmd>Telescope current_buffer_fuzzy_find<CR>',
		desc = 'grep buffer',
		mode = 'n'
	},
	-- grep globally
	{
		'<leader>fg',
		'<cmd>Telescope live_grep<CR>',
		desc = 'grep global',
		mode = 'n'
	},
	-- buffer management
	{
		'<leader>fb',
		'<cmd>Telescope buffers<CR>',
		desc = 'buffers',
		mode = 'n'
	},
	{
		'<leader>fr',
		'<cmd>Telescope oldfiles<CR>',
		desc = 'recent files',
		mode = 'n'
	},
	{
		'<leader>fq',
		'<cmd>Telescope quickfix<CR>',
		desc = 'quickfix',
		mode = 'n'
	},
	-- git integration
	{
		'<leader>fs',
		'<cmd>Telescope git_status<CR>',
		desc = 'git status',
		mode = 'n'
	},
	{
		'<leader>fl',
		'<cmd>Telescope git_commits<CR>',
		desc = 'git commits',
		mode = 'n'
	},
	{
		'<leader>fh',
		'<cmd>Telescope git_bcommits<CR>',
		desc = 'buffer commits',
		mode = 'n'
	},
	{
		'<leader>gb',
		'<cmd>Telescope git_branches<CR>',
		desc = 'git branches',
		mode = 'n'
	},
	-- advanced search
	{
		'<leader>fw',
		'<cmd>Telescope grep_string<CR>',
		desc = 'find word',
		mode = 'n'
	},
	{
		'<leader>fW',
		'<cmd>Telescope current_buffer_fuzzy_find<CR>',
		desc = 'find word in buffer',
		mode = 'n'
	},
	{
		'<leader>f/',
		'<cmd>Telescope search_history<CR>',
		desc = 'search history',
		mode = 'n'
	},
	{
		'<leader>f:',
		'<cmd>Telescope command_history<CR>',
		desc = 'command history',
		mode = 'n'
	},
	-- lsp/diagnostics
	{
		'<leader>fd',
		'<cmd>Telescope diagnostics<CR>',
		desc = 'diagnostics',
		mode = 'n'
	},
	{
		'<leader>fD',
		'<cmd>Telescope diagnostics bufnr=0<CR>',
		desc = 'buffer diagnostics',
		mode = 'n'
	},
	{
		'<leader>fS',
		'<cmd>Telescope lsp_document_symbols<CR>',
		desc = 'buffer symbols',
		mode = 'n'
	},
	{
		'<leader>fws',
		'<cmd>Telescope lsp_workspace_symbols<CR>',
		desc = 'workspace symbols',
		mode = 'n'
	},
	{
		'<leader>.',
		function()
			vim.lsp.buf.code_action()
		end,
		desc = 'code actions',
		mode = 'n'
	},
	-- help & documentation
	{
		'<leader>fk',
		'<cmd>Telescope keymaps<CR>',
		desc = 'keymaps',
		mode = 'n'
	},
	{
		'<leader>fH',
		'<cmd>Telescope help_tags<CR>',
		desc = 'help tags',
		mode = 'n'
	},
	{
		'<leader>fm',
		'<cmd>Telescope man_pages<CR>',
		desc = 'man pages',
		mode = 'n'
	},
	-- utility
	{
		'<leader>ft',
		'<cmd>Telescope filetypes<CR>',
		desc = 'file types',
		mode = 'n'
	},
	{
		'<leader>fo',
		'<cmd>Telescope vim_options<CR>',
		desc = 'vim options',
		mode = 'n'
	},
	{
		'<leader>fj',
		'<cmd>Telescope jumplist<CR>',
		desc = 'jumplist',
		mode = 'n'
	},
	{
		'<leader>fp',
		'<cmd>Telescope projects<CR>',
		desc = 'projects',
		mode = 'n'
	}
})