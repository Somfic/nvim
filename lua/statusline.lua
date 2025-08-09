local M = {}

-- cache for git output
local cache = {
	directory = '',
	branch = '',
	status = '',
	combined_result = '',
	last_update = 0,
	update_interval = 2000 -- ms
}

-- get current directory name
local function get_directory()
	local filename = vim.fn.expand('%:t')
	if filename ~= '' then
		-- show relative path from cwd to file
		local filepath = vim.fn.expand('%:p')
		local cwd = vim.fn.getcwd()
		local relative_path = vim.fn.fnamemodify(filepath, ':~:.')
		return relative_path
	else
		-- no file open, show working directory
		return vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
	end
end

-- get git branch using native git command
local function get_git_branch()
	local handle = io.popen('git branch --show-current 2>/dev/null')
	if not handle then return '' end
	local result = handle:read('*a')
	handle:close()

	if result and result ~= '' then
		local clean = result:gsub('\n', ''):gsub('^%s*', ''):gsub('%s*$', '')
		return clean ~= '' and clean or ''
	end
	return ''
end

-- get git status using native git command
local function get_git_status()
	local handle = io.popen('git status --porcelain 2>/dev/null')
	if not handle then return '' end
	local result = handle:read('*a')
	handle:close()

	if result and result ~= '' then
		local lines = {}
		for line in result:gmatch('[^\n]+') do
			table.insert(lines, line)
		end

		if #lines > 0 then
			local status_parts = {}
			local modified = 0
			local added = 0
			local deleted = 0
			local untracked = 0

			for _, line in ipairs(lines) do
				local status_code = line:sub(1, 2)
				if status_code:match('M.') or status_code:match('.M') then
					modified = modified + 1
				elseif status_code:match('A.') or status_code:match('.A') then
					added = added + 1
				elseif status_code:match('D.') or status_code:match('.D') then
					deleted = deleted + 1
				elseif status_code:match('??') then
					untracked = untracked + 1
				end
			end

			if modified > 0 then table.insert(status_parts, '󰏫 ' .. modified) end
			if added > 0 then table.insert(status_parts, '󰐕 ' .. added) end
			if deleted > 0 then table.insert(status_parts, '󰍴 ' .. deleted) end
			if untracked > 0 then table.insert(status_parts, '󰋖 ' .. untracked) end

			return table.concat(status_parts, ' ')
		end
	end
	return ''
end

-- update cache
local function update_cache()
	local current_time = vim.loop.now()

	-- only update if enough time has passed
	if current_time - cache.last_update < cache.update_interval then
		return false
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

	-- add git branch with icon
	if cache.branch ~= '' then
		table.insert(parts, '  ' .. cache.branch)
	end

	-- add git status with icons
	if cache.status ~= '' then
		table.insert(parts, '  ' .. cache.status)
	end

	cache.combined_result = table.concat(parts, '')
	if cache.combined_result ~= '' then
		cache.combined_result = cache.combined_result .. ' '
	end

	return true
end

-- force initial update
local function force_update()
	cache.last_update = 0
	update_cache()
end

-- get combined status string for statusline
function M.get_status()
	update_cache()
	return cache.combined_result
end

-- get raw parts for manual statusline construction
function M.get_parts()
	update_cache()
	return {
		directory = cache.directory,
		branch = cache.branch,
		status = cache.status
	}
end

-- expose force update function for testing
M.force_update = force_update

-- force initial update
force_update()
return M

