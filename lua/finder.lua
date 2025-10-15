vim.pack.add({
	{ src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
})

require('telescope').setup({
	defaults = {
		file_ignore_patterns = { 'node_modules', '.git/' },
		sorting_strategy = 'ascending',
	},
	pickers = {
		current_buffer_fuzzy_find = {
			tiebreak = function(current, existing, prompt)
				-- Prefer exact substring matches
				local current_lower = current.ordinal:lower()
				local existing_lower = existing.ordinal:lower()
				local prompt_lower = prompt:lower()

				local current_exact = current_lower:find(prompt_lower, 1, true)
				local existing_exact = existing_lower:find(prompt_lower, 1, true)

				if current_exact and not existing_exact then
					return true
				elseif existing_exact and not current_exact then
					return false
				end

				return current.score < existing.score
			end,
		},
		live_grep = {
			tiebreak = function(current, existing, prompt)
				-- Prefer exact substring matches
				local current_lower = current.ordinal:lower()
				local existing_lower = existing.ordinal:lower()
				local prompt_lower = prompt:lower()

				local current_exact = current_lower:find(prompt_lower, 1, true)
				local existing_exact = existing_lower:find(prompt_lower, 1, true)

				if current_exact and not existing_exact then
					return true
				elseif existing_exact and not current_exact then
					return false
				end

				return current.score < existing.score
			end,
		}
	},
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


require('which-key').add({
	{ '<leader>f',  group = 'find' },
	{
		'<leader>ff', -- git version
		'<cmd>Telescope git_files<CR>',
		desc = 'files',
		mode = 'n',
		cond = function()
			return vim
			    .fn.isdirectory('.git') == 1
		end
	},
	{
		'<leader>ff', -- non-git version
		'<cmd>Telescope find_files<CR>',
		desc = 'files',
		mode = 'n',
		cond = function()
			return vim
			    .fn.isdirectory('.git') == 0
		end
	},

	{
		'<leader>fh',
		'<cmd>Telescope current_buffer_fuzzy_find<CR>',
		desc = 'find here',
		mode = 'n'
	},
	{
		'<leader>fg',
		'<cmd>Telescope live_grep<CR>',
		desc = 'find globally',
		mode = 'n'
	},

	--  find symbols
	{ '<leader>fs', group = 'symbols' },
	{
		'<leader>fsh',
		'<cmd>Telescope lsp_document_symbols<CR>',
		desc = 'here',
		mode = 'n'
	},
	{
		'<leader>fsg',
		'<cmd>Telescope lsp_dynamic_workspace_symbols<CR>',
		desc = 'globally',
		mode = 'n'
	},

	-- find words
	{ '<leader>fw', group = 'words' },
	{
		'<leader>fwh',
		'<cmd>Telescope current_buffer_fuzzy_find<CR>',
		desc = 'here',
		mode = 'n'
	},
	{
		'<leader>fwg',
		'<cmd>Telescope grep_string<CR>',
		desc = 'globally',
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
})
