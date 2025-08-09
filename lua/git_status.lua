local M = {}

-- cache for starship output
local cache = {
	directory = '',
	branch = '',
	status = '',
	combined_result = '',
	last_update = 0,
	update_interval = 2000 -- ms - increased for better performance
}


-- ANSI color code mappings to Neovim highlight groups
local ansi_colors = {
	['30'] = 'StarshipBlack',
	['31'] = 'StarshipRed',
	['32'] = 'StarshipGreen',
	['33'] = 'StarshipYellow',
	['34'] = 'StarshipBlue',
	['35'] = 'StarshipMagenta',
	['36'] = 'StarshipCyan',
	['37'] = 'StarshipWhite',
	['90'] = 'StarshipBrightBlack',
	['91'] = 'StarshipBrightRed',
	['92'] = 'StarshipBrightGreen',
	['93'] = 'StarshipBrightYellow',
	['94'] = 'StarshipBrightBlue',
	['95'] = 'StarshipBrightMagenta',
	['96'] = 'StarshipBrightCyan',
	['97'] = 'StarshipBrightWhite',
	['1;31'] = 'StarshipBoldRed',
	['1;32'] = 'StarshipBoldGreen',
	['1;33'] = 'StarshipBoldYellow',
	['1;34'] = 'StarshipBoldBlue',
	['1;35'] = 'StarshipBoldMagenta',
	['1;36'] = 'StarshipBoldCyan',
	['1;37'] = 'StarshipBoldWhite',
}

-- setup highlight groups for starship colors
local function setup_highlights()
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

-- convert ANSI codes to Neovim statusline format
local function ansi_to_statusline(str)
	if not str or str == '' then return '' end

	local result = str

	-- replace specific ANSI color codes with statusline highlight groups
	for code, group in pairs(ansi_colors) do
		-- escape the code for pattern matching and try both \027 and \x1b
		local pattern1 = '\027%[' .. code:gsub('([%;])', '%%%;') .. 'm'
		local pattern2 = '\x1b%[' .. code:gsub('([%;])', '%%%;') .. 'm'
		result = result:gsub(pattern1, '%#' .. group .. '#')
		result = result:gsub(pattern2, '%#' .. group .. '#')
	end

	-- replace reset codes with normal highlighting
	result = result:gsub('\027%[0m', '%#Normal#')
	result = result:gsub('\x1b%[0m', '%#Normal#')

	-- remove any remaining ANSI codes
	result = result:gsub('\027%[[%d;]*m', '')
	result = result:gsub('\x1b%[[%d;]*m', '')

	return result
end

-- get directory using starship (simplified - just get the text)
local function get_directory()
	local handle = io.popen('starship module directory 2>nul')
	if not handle then return '' end
	local result = handle:read('*a')
	handle:close()

	if result and result ~= '' then
		-- strip ANSI and clean up
		local clean = result:gsub('\027%[[%d;]*m', ''):gsub('\n', ''):gsub('^%s*', ''):gsub('%s*$', '')

		-- add current filename if available
		local filename = vim.fn.expand('%:t')
		if filename ~= '' then
			clean = clean .. '/' .. filename
		end

		return clean ~= '' and ('%#StarshipBoldCyan#' .. clean .. '%#Normal#') or ''
	end
	return ''
end

-- get git branch using starship (simplified)
local function get_git_branch()
	local handle = io.popen('starship module git_branch 2>nul')
	if not handle then return '' end
	local result = handle:read('*a')
	handle:close()

	if result and result ~= '' then
		-- strip ANSI and clean up, remove "on " prefix
		local clean = result:gsub('\027%[[%d;]*m', ''):gsub('on ', ''):gsub('\n', ''):gsub('^%s*', ''):gsub(
		'%s*$', '')
		return clean ~= '' and ('%#StarshipBoldMagenta#' .. clean .. '%#Normal#') or ''
	end
	return ''
end

-- get git status using starship (simplified)
local function get_git_status()
	local handle = io.popen('starship module git_status 2>nul')
	if not handle then return '' end
	local result = handle:read('*a')
	handle:close()

	if result and result ~= '' then
		-- strip ANSI and clean up
		local clean = result:gsub('\027%[[%d;]*m', ''):gsub('\n', ''):gsub('^%s*', ''):gsub('%s*$', '')
		return clean ~= '' and ('%#StarshipBoldRed#' .. clean .. '%#Normal#') or ''
	end
	return ''
end

-- update cache
local function update_cache()
	local current_time = vim.loop.now()

	-- only update if enough time has passed
	if current_time - cache.last_update < cache.update_interval then
		return false -- indicate no update occurred
	end

	cache.last_update = current_time
	cache.directory = get_directory()
	cache.branch = get_git_branch()
	cache.status = get_git_status()

	-- pre-compute the combined result
	local parts = {}

	-- add directory
	if cache.directory ~= '' then
		table.insert(parts, ' ' .. cache.directory)
	end

	-- add git branch
	if cache.branch ~= '' then
		table.insert(parts, ' ' .. cache.branch)
	end

	-- add git status
	if cache.status ~= '' then
		table.insert(parts, cache.status)
	end

	cache.combined_result = table.concat(parts, '')
	if cache.combined_result ~= '' then
		cache.combined_result = cache.combined_result .. ' %#Normal#'
	end

	return true -- indicate update occurred
end

-- force initial update
local function force_update()
	cache.last_update = 0
	update_cache()
end

-- debug function to check ANSI conversion
function M.debug_ansi(str)
	return ansi_to_statusline(str or '')
end

-- get combined status string for statusline
function M.get_status()
	update_cache()
	-- for statusline %{} evaluation, we need to return a statusline expression
	return cache.combined_result
end

-- alternative: get raw parts for manual statusline construction
function M.get_parts()
	update_cache()
	return {
		directory = cache.directory,
		branch = cache.branch,
		status = cache.status
	}
end

-- initialize highlights when module is loaded
setup_highlights()

-- expose force update function for testing
M.force_update = force_update

-- force initial update
force_update()
return M
