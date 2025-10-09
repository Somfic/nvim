-- README preview mode functionality
local M = {}

local preview_buf = nil
local preview_win = nil

-- convert markdown to simple text format for preview
local function format_markdown(lines)
	local formatted = {}
	local in_code_block = false
	local code_indent = "    "

	for _, line in ipairs(lines) do
		if line:match("^```") then
			in_code_block = not in_code_block
			if in_code_block then
				table.insert(formatted, "┌" .. string.rep("─", 60) .. "┐")
			else
				table.insert(formatted, "└" .. string.rep("─", 60) .. "┘")
			end
		elseif in_code_block then
			table.insert(formatted, "│ " .. line .. string.rep(" ", math.max(0, 58 - #line)) .. " │")
		else
			-- format headers
			local h1_match = line:match("^# (.+)")
			if h1_match then
				table.insert(formatted, "")
				table.insert(formatted, "━━ " .. h1_match:upper() .. " ━━")
				table.insert(formatted, "")
			else
				local h2_match = line:match("^## (.+)")
				if h2_match then
					table.insert(formatted, "")
					table.insert(formatted, "▶ " .. h2_match)
					table.insert(formatted, string.rep("─", #h2_match + 2))
				else
					local h3_match = line:match("^### (.+)")
					if h3_match then
						table.insert(formatted, "")
						table.insert(formatted, "• " .. h3_match)
					else
						-- format lists
						local list_match = line:match("^%s*[%-%*%+] (.+)")
						if list_match then
							table.insert(formatted, "  ◦ " .. list_match)
						else
							-- format bold and italic (simple approximation)
							local formatted_line = line
							formatted_line = formatted_line:gsub("%*%*(.-)%*%*", "%1") -- remove bold
							formatted_line = formatted_line:gsub("%*(.-)%*", "%1")     -- remove italic
							formatted_line = formatted_line:gsub("`(.-)`", "«%1»")     -- format inline code

							if formatted_line:trim() ~= "" then
								table.insert(formatted, formatted_line)
							else
								table.insert(formatted, "")
							end
						end
					end
				end
			end
		end
	end

	return formatted
end

-- create or update preview window
function M.show_preview()
	local current_buf = vim.api.nvim_get_current_buf()
	local current_file = vim.api.nvim_buf_get_name(current_buf)

	-- check if current file is a markdown file
	if not current_file:match("%.md$") and not current_file:match("README") then
		vim.notify("Preview mode is for markdown/README files only", vim.log.levels.WARN)
		return
	end

	-- get current buffer content
	local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
	local formatted_lines = format_markdown(lines)

	-- calculate window dimensions
	local width = math.min(math.floor(vim.o.columns * 0.6), 100)
	local height = math.min(math.floor(vim.o.lines * 0.8), #formatted_lines + 4)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- create preview buffer if it doesn't exist
	if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
		preview_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(preview_buf, 'buftype', 'nofile')
		vim.api.nvim_buf_set_option(preview_buf, 'swapfile', false)
		vim.api.nvim_buf_set_option(preview_buf, 'filetype', 'markdown')
	end

	-- set buffer content
	vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, formatted_lines)

	-- create or update preview window
	if preview_win and vim.api.nvim_win_is_valid(preview_win) then
		vim.api.nvim_win_set_config(preview_win, {
			relative = 'editor',
			row = row,
			col = col,
			width = width,
			height = height
		})
	else
		preview_win = vim.api.nvim_open_win(preview_buf, false, {
			relative = 'editor',
			row = row,
			col = col,
			width = width,
			height = height,
			style = 'minimal',
			border = 'rounded',
			title = ' README Preview ',
			title_pos = 'center'
		})

		-- set window options
		vim.api.nvim_win_set_option(preview_win, 'wrap', true)
		vim.api.nvim_win_set_option(preview_win, 'linebreak', true)

		-- add highlighting
		local ns = vim.api.nvim_create_namespace('readme_preview')
		for i, line in ipairs(formatted_lines) do
			if line:match("^━━") then
				vim.api.nvim_buf_add_highlight(preview_buf, ns, 'Title', i-1, 0, -1)
			elseif line:match("^▶") then
				vim.api.nvim_buf_add_highlight(preview_buf, ns, 'Function', i-1, 0, -1)
			elseif line:match("^•") then
				vim.api.nvim_buf_add_highlight(preview_buf, ns, 'Keyword', i-1, 0, -1)
			elseif line:match("^┌") or line:match("^└") or line:match("^│") then
				vim.api.nvim_buf_add_highlight(preview_buf, ns, 'Comment', i-1, 0, -1)
			end
		end
	end

	-- auto-close preview when leaving the markdown buffer
	vim.api.nvim_create_autocmd({'BufLeave', 'WinLeave'}, {
		buffer = current_buf,
		once = true,
		callback = function()
			M.close_preview()
		end
	})
end

-- close preview window
function M.close_preview()
	if preview_win and vim.api.nvim_win_is_valid(preview_win) then
		vim.api.nvim_win_close(preview_win, true)
		preview_win = nil
	end
end

-- toggle preview window
function M.toggle_preview()
	if preview_win and vim.api.nvim_win_is_valid(preview_win) then
		M.close_preview()
	else
		M.show_preview()
	end
end

return M