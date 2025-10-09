-- lsp progress tracking
local progress = {}
local progress_spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local spinner_index = 1
local progress_timer = nil
local progress_popup = nil

-- load unified language configuration
local lang_config = require('lsp.config')

-- build language icons and colors from unified config
local language_icons = {}
local icon_colors = {}

for lang, config in pairs(lang_config) do
	if config.lsp_server and config.icon then
		language_icons[config.lsp_server] = config.icon
		if config.color then
			icon_colors[config.lsp_server] = config.color
		end
	end
end

-- add graphql icon for template literal detection
language_icons.graphql = lang_config.graphql.icon

-- fallback icon for unknown LSP servers
local fallback_icon = '󰒋'


local lsp_state = {
	attached_clients = {},
	loading_clients = {},
	is_loading = false,
}

-- create or update progress popup
local function update_progress_popup()
	local active_progress = {}
	for token, prog in pairs(progress) do
		table.insert(active_progress, prog)
	end

	if #active_progress == 0 then
		-- close popup if no progress
		if progress_popup and vim.api.nvim_win_is_valid(progress_popup) then
			vim.api.nvim_win_close(progress_popup, true)
			progress_popup = nil
		end
		return
	end

	-- build progress message
	local lines = {}
	for _, prog in ipairs(active_progress) do
		local spinner = progress_spinner[spinner_index]
		local msg = spinner .. ' ' .. prog.title

		if prog.message and #prog.message < 60 then
			table.insert(lines, msg)
			table.insert(lines, '  ' .. prog.message)
		else
			table.insert(lines, msg)
		end
	end

	-- calculate popup position (right-aligned above statusline)
	local width = 0
	for _, line in ipairs(lines) do
		width = math.max(width, vim.fn.strchars(line))
	end
	width = math.min(width + 2, 80) -- add padding, max 80 chars

	local height = #lines
	local row = vim.o.lines - height - 4 -- one line higher above statusline
	local col = vim.o.columns - width - 1 -- right aligned

	-- create or update popup
	if progress_popup and vim.api.nvim_win_is_valid(progress_popup) then
		local buf = vim.api.nvim_win_get_buf(progress_popup)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.api.nvim_win_set_config(progress_popup, {
			relative = 'editor',
			row = row,
			col = col,
			width = width,
			height = height
		})
	else
		local buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		progress_popup = vim.api.nvim_open_win(buf, false, {
			relative = 'editor',
			row = row,
			col = col,
			width = width,
			height = height,
			style = 'minimal',
			border = 'rounded',
			focusable = false,
			zindex = 1000
		})

		-- set popup highlighting
		vim.api.nvim_win_set_hl_ns(progress_popup, vim.api.nvim_create_namespace('lsp_progress_popup'))
		vim.api.nvim_set_hl(0, 'LspProgressPopup', { bg = '#2d2d2d', fg = '#ffffff' })
		vim.api.nvim_win_set_option(progress_popup, 'winhl', 'Normal:LspProgressPopup')
	end
end

-- update spinner animation
local function update_spinner()
	spinner_index = (spinner_index % #progress_spinner) + 1
	update_progress_popup()
	vim.cmd('redrawstatus')
end



-- track lsp client attach/detach
function _G.lsp_client_attached(client_name)
	lsp_state.attached_clients[client_name] = true
	lsp_state.is_loading = false
	vim.cmd('redrawstatus')
end

-- Update statusline when buffer content changes (to show/hide GraphQL icon)
vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'BufEnter' }, {
	pattern = '*.ts,*.tsx,*.js,*.jsx',
	callback = function()
		vim.cmd('redrawstatus')
	end
})

function _G.lsp_client_detached(client_name)
	lsp_state.attached_clients[client_name] = nil
	-- stop loading state if this was the last client
	local has_clients = false
	for _ in pairs(lsp_state.attached_clients) do
		has_clients = true
		break
	end
	if not has_clients then
		lsp_state.is_loading = false
	end
	vim.cmd('redrawstatus')
end

function _G.lsp_client_loading(client_name)
	-- add client to show icon immediately, but mark as loading
	lsp_state.attached_clients[client_name] = true
	lsp_state.is_loading = true
	vim.cmd('redrawstatus')
end

-- get current progress for statusline (left side)
function _G.get_lsp_status()
	local active_progress = {}
	for token, prog in pairs(progress) do
		table.insert(active_progress, prog)
	end

	-- show progress spinner if active
	if #active_progress > 0 then
		local spinner = progress_spinner[spinner_index]
		local status = active_progress[1]
		local msg = spinner .. ' ' .. status.title

		if status.percentage then
			msg = msg .. ' (' .. status.percentage .. '%)'
		end

		if status.message and #status.message < 50 then
			msg = msg .. ': ' .. status.message
		end

		return ' ' .. msg .. ' '
	end

	return ''
end

-- check if current buffer has GraphQL content
local function has_graphql_content()
	local filetype = vim.bo.filetype
	if filetype == 'typescript' or filetype == 'typescriptreact' or filetype == 'javascript' or filetype == 'javascriptreact' then
		local lines = vim.api.nvim_buf_get_lines(0, 0, 100, false) -- check first 100 lines
		for _, line in ipairs(lines) do
			if line:match('gql`') or line:match('graphql`') or line:match('useQuery') or line:match('useMutation') or line:match('@apollo/client') then
				return true
			end
		end
	end
	return false
end

-- get language icons for statusline (right side)
function _G.get_lsp_icons()
	local icons = {}
	for client_name, _ in pairs(lsp_state.attached_clients) do
		local icon = language_icons[client_name] or fallback_icon
		table.insert(icons, icon)
	end
	
	-- Add GraphQL icon if current buffer has GraphQL content
	if has_graphql_content() then
		table.insert(icons, language_icons.graphql)
	end

	if #icons > 0 then
		return ' ' .. table.concat(icons, ' ') .. ' '
	end

	return ''
end

-- combined progress and icons (right side) - icons with percentage
function _G.get_lsp_combined()
	local active_progress = {}
	for token, prog in pairs(progress) do
		table.insert(active_progress, prog)
	end

	-- get language icons
	local icons = {}
	for client_name, _ in pairs(lsp_state.attached_clients) do
		local icon = language_icons[client_name] or fallback_icon
		table.insert(icons, icon)
	end
	
	-- Add GraphQL icon if current buffer has GraphQL content
	if has_graphql_content() then
		table.insert(icons, language_icons.graphql)
	end

	local icon_str = #icons > 0 and table.concat(icons, ' ') or ''

	-- show percentage with icons if progress is active
	if #active_progress > 0 and active_progress[1].percentage then
		local percentage = active_progress[1].percentage .. '%'
		if icon_str ~= '' then
			return ' ' .. percentage .. ' ' .. icon_str .. ' '
		else
			return ' ' .. percentage .. ' '
		end
	end

	-- show only icons when no progress or no percentage
	if icon_str ~= '' then
		return ' ' .. icon_str .. ' '
	end

	return ''
end

-- handle lsp progress notifications (rust-analyzer indexing, etc.)
vim.lsp.handlers['$/progress'] = function(_, result, ctx)
	local client_id = ctx.client_id
	local client = vim.lsp.get_client_by_id(client_id)
	if not client then return end

	local value = result.value
	if not value then return end

	local token = result.token

	if value.kind == 'begin' then
		progress[token] = {
			title = value.title,
			message = value.message,
			percentage = value.percentage
		}
		-- start spinner animation when progress begins
		if progress_timer then
			vim.fn.timer_stop(progress_timer)
		end
		progress_timer = vim.fn.timer_start(100, update_spinner, { ['repeat'] = -1 })

		-- trigger loading state
		_G.lsp_client_loading(client.name)
	elseif value.kind == 'report' then
		if progress[token] then
			progress[token].message = value.message or progress[token].message
			progress[token].percentage = value.percentage or progress[token].percentage
		end
	elseif value.kind == 'end' then
		if progress[token] then
			progress[token] = nil
		end
		-- stop spinner when no more progress
		local has_progress = false
		for _ in pairs(progress) do
			has_progress = true
			break
		end
		if not has_progress and progress_timer then
			vim.fn.timer_stop(progress_timer)
			progress_timer = nil

			-- mark as not loading and move to attached
			lsp_state.is_loading = false
			_G.lsp_client_attached(client.name)

			-- close progress popup
			update_progress_popup()
		end
	end
end
