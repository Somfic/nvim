vim.opt.number = false
vim.opt.relativenumber = false
-- show line numbers every 5 lines + git signs + diagnostic signs
vim.opt.statuscolumn = "%s%{v:lnum % 5 == 0 ? printf(' %3d ', v:lnum) : '     '}"
vim.opt.signcolumn = 'auto:2'
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.swapfile = false

require('keybindings')

-- auto-write files
vim.api.nvim_create_autocmd('InsertLeave', {
	callback = function()
		if vim.bo.modified and not vim.bo.readonly and vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
			-- Prioritize ESLint for JS/TS/React files
			local ft = vim.bo.filetype
			if ft == 'typescript' or ft == 'typescriptreact' or ft == 'javascript' or ft == 'javascriptreact' then
				vim.lsp.buf.format({
					filter = function(client)
						-- Prefer ESLint for formatting
						return client.name == 'eslint'
					end
				})
			else
				vim.lsp.buf.format()
			end
			vim.cmd('silent! write')
		end
	end

})



vim.keymap.set('n', '<leader>cd', ':Oil<CR>')

vim.pack.add({
	{ src = 'https://github.com/vague2k/vague.nvim' },
	{ src = 'https://github.com/stevearc/oil.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/lewis6991/gitsigns.nvim' },
	{ src = 'https://github.com/nvim-tree/nvim-web-devicons' },
	{ src = 'https://github.com/echasnovski/mini.icons' },
	{ src = 'https://github.com/windwp/nvim-autopairs' },
	{ src = 'https://github.com/windwp/nvim-ts-autotag' },
	{ src = 'https://github.com/github/copilot.vim' }
})

require('oil').setup()

require('finder')
require('git_signs')
require('lsp')

require('nvim-autopairs').setup({
	check_ts = true,
	ts_config = {
		lua = { 'string', 'source' },
		javascript = { 'string', 'template_string' },
		typescript = { 'string', 'template_string' },
	}
})

require('nvim-ts-autotag').setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false
	},
	per_filetype = {
		['html'] = { enable_close = false },
		['jsx'] = { enable_close = true },
		['tsx'] = { enable_close = true },
		['javascript'] = { enable_close = true },
		['typescript'] = { enable_close = true },
	}
})


-- git status
local git_status = require('statusline')

-- global function to get git status for statusline
function _G.get_git_status()
	return git_status.get_status()
end

-- build statusline with proper highlighting
function _G.build_git_statusline()
	local parts = git_status.get_parts()
	local result = {}

	-- add directory with highlight
	if parts.directory and parts.directory ~= '' then
		table.insert(result, ' ' .. parts.directory)
	end

	-- add git branch with highlight
	if parts.branch and parts.branch ~= '' then
		table.insert(result, ' ' .. parts.branch)
	end

	-- add git status with highlight
	if parts.status and parts.status ~= '' then
		table.insert(result, parts.status)
	end

	return table.concat(result, '') .. (next(result) and ' ' or '')
end

-- theming
require('vague').setup({ transparent = true })
vim.cmd('colorscheme vague')
vim.cmd(':hi statusline guibg=NONE')
vim.opt.winborder = 'rounded'

-- get file type icon
local function get_filetype_icon()
	local filename = vim.fn.expand('%:t')
	local extension = vim.fn.expand('%:e')

	if filename == '' then return '' end

	local icons = {
		-- JSON, YAML, TOML
		json = '󰘦',
		jsonc = '󰘦',
		yaml = '',
		yml = '',
		toml = '',

		-- Programming languages
		lua = '',
		rust = '',
		rs = '',
		js = '',
		jsx = '',
		ts = '',
		tsx = '',
		java = '',
		py = '',

		-- Web technologies
		html = '',
		css = '',
		scss = '',

		-- Config files
		dockerfile = '',
		gitignore = '',

		-- Documents
		md = '',
		txt = '',

		-- Other
		xml = '󰗀',
		sql = '',
		sh = '',
		zsh = '',
		bash = '',
	}

	-- special filenames
	if filename == 'package.json' then return '' end
	if filename == 'tsconfig.json' or filename:match('tsconfig%..*%.json') then return '' end
	if filename == 'Cargo.toml' then return '' end
	if filename == 'Dockerfile' then return '' end
	if filename:match('%.env') then return '' end

	return icons[extension] or ''
end

-- cache for statusline parts
local statusline_cache = {
	git_part = '',
	last_file = '',
	last_git_update = 0
}

-- build git part of statusline (slow part)
local function update_git_statusline()
	local parts = git_status.get_parts()
	local git_parts = {}

	-- add git branch with highlight
	if parts.branch and parts.branch ~= '' then
		table.insert(git_parts, ' ' .. parts.branch)
	end

	-- add git status with highlight
	if parts.status and parts.status ~= '' then
		table.insert(git_parts, parts.status)
	end

	statusline_cache.git_part = table.concat(git_parts, '')
	statusline_cache.last_git_update = vim.loop.now()
end

-- build directory part (fast part)
local function get_directory_part()
	local filename = vim.fn.expand('%:t')
	local filepath = vim.fn.expand('%:p')

	if filename == '' then
		-- no file open, show working directory
		local dir_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
		return dir_name
	else
		-- show relative path from cwd to file
		local cwd = vim.fn.getcwd()
		local relative_path = vim.fn.fnamemodify(filepath, ':~:.')

		-- add file type icon
		local icon = get_filetype_icon()
		local display = relative_path

		if icon ~= '' then
			display = icon .. ' ' .. display
		end

		return display
	end
end

-- update complete statusline
local function update_statusline()
	local current_file = vim.fn.expand('%:p')
	local current_time = vim.loop.now()

	-- update git part only every 3 seconds
	if current_time - statusline_cache.last_git_update > 3000 then
		update_git_statusline()
	end

	-- always update directory part (it's fast)
	local directory_part = ' ' .. get_directory_part()

	vim.opt.statusline = '▎' ..
	    directory_part .. statusline_cache.git_part .. '%=' .. '%{v:lua.get_lsp_combined()}' .. ' '
	statusline_cache.last_file = current_file
end

-- update statusline on file changes (always fast update)
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
	callback = function()
		update_statusline()
	end
})

-- update git info when leaving insert mode or changing files
vim.api.nvim_create_autocmd({ 'InsertLeave', 'BufWritePost' }, {
	callback = function()
		update_git_statusline()
		update_statusline()
	end
})

-- initial statusline update
update_git_statusline()
update_statusline()
