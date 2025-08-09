vim.opt.number = false
vim.opt.relativenumber = false
-- show line numbers every 5 lines + git signs + diagnostic signs
vim.opt.statuscolumn = "%s%{v:lnum % 5 == 0 ? printf('%4d ', v:lnum) : '     '}"
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

-- auto-write files
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufLeave', 'FocusLost' }, {
	callback = function()
		if vim.bo.modified and not vim.bo.readonly and vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
			vim.cmd('silent! write')
		end
	end
})
vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', '<leader>cd', ':Oil<CR>')
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)


vim.pack.add({
	{ src = 'https://github.com/vague2k/vague.nvim' },
	{ src = 'https://github.com/stevearc/oil.nvim' },
	{ src = 'https://github.com/nvim-telescope/telescope.nvim' },
	{ src = 'https://github.com/nvim-lua/plenary.nvim' },
	{ src = 'https://github.com/lewis6991/gitsigns.nvim' },
})

-- telescope
require('telescope').setup()

-- oil
require('oil').setup()

-- gitsigns
require('gitsigns_config')

-- LSP configuration
require('lsp')

-- prettier diagnostics
require('diagnostics_config')

-- git status
local git_status = require('git_status')

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

-- create starship highlight groups after colorscheme is loaded
local function setup_starship_highlights()
	local highlights = {
		StarshipBlack = { fg = '#44475a' },
		StarshipRed = { fg = '#ff5555' },
		StarshipGreen = { fg = '#50fa7b' },
		StarshipYellow = { fg = '#f1fa8c' },
		StarshipBlue = { fg = '#8be9fd' },
		StarshipMagenta = { fg = '#ff79c6' },
		StarshipCyan = { fg = '#8be9fd' },
		StarshipWhite = { fg = '#f8f8f2' },
		StarshipBrightBlack = { fg = '#6272a4' },
		StarshipBrightRed = { fg = '#ff6e6e' },
		StarshipBrightGreen = { fg = '#69ff94' },
		StarshipBrightYellow = { fg = '#ffffa5' },
		StarshipBrightBlue = { fg = '#d6acff' },
		StarshipBrightMagenta = { fg = '#ff92df' },
		StarshipBrightCyan = { fg = '#a4ffff' },
		StarshipBrightWhite = { fg = '#ffffff' },
		StarshipBoldRed = { fg = '#ff5555', bold = true },
		StarshipBoldGreen = { fg = '#50fa7b', bold = true },
		StarshipBoldYellow = { fg = '#f1fa8c', bold = true },
		StarshipBoldBlue = { fg = '#8be9fd', bold = true },
		StarshipBoldMagenta = { fg = '#ff79c6', bold = true },
		StarshipBoldCyan = { fg = '#8be9fd', bold = true },
		StarshipBoldWhite = { fg = '#f8f8f2', bold = true },
	}

	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end
end

setup_starship_highlights()

-- function to manually test highlights
function _G.test_highlights()
	setup_starship_highlights()
	vim.opt.statusline =
	'%#StarshipBoldCyan#CYAN%#Normal# %#StarshipBoldMagenta#MAGENTA%#Normal# %=%{v:lua.get_lsp_combined()}'
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
		return '%#StarshipBoldCyan#' .. dir_name .. '%#Normal#'
	else
		-- show relative path from cwd to file
		local cwd = vim.fn.getcwd()
		local relative_path = vim.fn.fnamemodify(filepath, ':~:.')

		-- if file is in cwd, show directory/filename
		-- if file is in subdirectory, show subdirectory/filename
		local display = relative_path

		return '%#StarshipBoldCyan#' .. display .. '%#Normal#'
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

	vim.opt.statusline = directory_part .. statusline_cache.git_part .. ' %=%{v:lua.get_lsp_combined()}'
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

-- debug function to check statusline
function _G.debug_statusline()
	local parts = git_status.get_parts()
	print("Directory:", vim.inspect(parts.directory))
	print("Branch:", vim.inspect(parts.branch))
	print("Status:", vim.inspect(parts.status))
	print("Current statusline:", vim.o.statusline)

	-- check if highlight groups exist
	local hl = vim.api.nvim_get_hl_by_name('StarshipBoldCyan', true)
	print("StarshipBoldCyan highlight:", vim.inspect(hl))

	-- test simple starship output
	local handle = io.popen('starship module directory')
	if handle then
		local raw = handle:read('*a')
		handle:close()
		print("Raw starship directory:", vim.inspect(raw))
	end
end
