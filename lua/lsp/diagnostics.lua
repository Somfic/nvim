-- prettier LSP diagnostics configuration

-- define diagnostic signs
local signs = {
	Error = " ",
	Warn = " ",
	Hint = "󰌵 ",
	Info = " "
}

-- set diagnostic signs with priority
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "", priority = 8 })
end

-- configure vim diagnostics
vim.diagnostic.config({
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
		format = function(diagnostic)
			return diagnostic.message
		end
	},
	signs = false, -- disable left gutter signs
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		format = function(diagnostic)
			return string.format("%s: %s", diagnostic.source, diagnostic.message)
		end,
	},
})

-- prettier diagnostic highlights
local diagnostic_highlights = {
	DiagnosticError = { fg = "#ff5555", bold = true },
	DiagnosticWarn = { fg = "#f1fa8c", bold = true },
	DiagnosticInfo = { fg = "#8be9fd", bold = true },
	DiagnosticHint = { fg = "#50fa7b", bold = true },
	DiagnosticVirtualTextError = { fg = "#ff5555", bg = "#2d1b1b" },
	DiagnosticVirtualTextWarn = { fg = "#f1fa8c", bg = "#2d2a1b" },
	DiagnosticVirtualTextInfo = { fg = "#8be9fd", bg = "#1b2d2d" },
	DiagnosticVirtualTextHint = { fg = "#50fa7b", bg = "#1b2d1f" },
	DiagnosticUnderlineError = { undercurl = true, sp = "#ff5555" },
	DiagnosticUnderlineWarn = { undercurl = true, sp = "#f1fa8c" },
	DiagnosticUnderlineInfo = { undercurl = true, sp = "#8be9fd" },
	DiagnosticUnderlineHint = { undercurl = true, sp = "#50fa7b" },
	-- full line background highlights
	DiagnosticLineError = { bg = "#3f1a1a" },
	DiagnosticLineWarn = { bg = "#3f3a1a" },
	DiagnosticLineInfo = { bg = "#1a1a3f" },
	DiagnosticLineHint = { bg = "#1a3f1a" },
}

-- apply diagnostic highlights
for group, opts in pairs(diagnostic_highlights) do
	vim.api.nvim_set_hl(0, group, opts)
end

-- keymaps for diagnostics
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Open diagnostic list' })

-- show diagnostics in hover window
vim.keymap.set('n', '<leader>dh', function()
	vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
end, { desc = 'Show diagnostic hover' })

-- create right-aligned diagnostic gutter with scrollbar
local function create_diagnostic_gutter()
	local ns = vim.api.nvim_create_namespace('diagnostic_right_gutter')
	
	vim.api.nvim_create_autocmd({ 'DiagnosticChanged', 'BufEnter', 'WinScrolled' }, {
		callback = function(args)
			local bufnr = args.buf or vim.api.nvim_get_current_buf()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end

			-- clear existing marks
			vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

			local diagnostics = vim.diagnostic.get(bufnr)
			local win = vim.fn.bufwinid(bufnr)
			if win == -1 then return end

			local win_width = vim.api.nvim_win_get_width(win)
			local win_height = vim.api.nvim_win_get_height(win)
			local line_count = vim.api.nvim_buf_line_count(bufnr)
			local topline = vim.fn.line('w0', win)
			local botline = vim.fn.line('w$', win)


			-- diagnostic icons in right gutter
			for _, diagnostic in ipairs(diagnostics) do
				if diagnostic.lnum >= topline - 1 and diagnostic.lnum <= botline - 1 then
					local icon = ""
					local hl_group = "DiagnosticError"
					
					if diagnostic.severity == vim.diagnostic.severity.ERROR then
						icon = " "
						hl_group = "DiagnosticError"
					elseif diagnostic.severity == vim.diagnostic.severity.WARN then
						icon = " "
						hl_group = "DiagnosticWarn"
					elseif diagnostic.severity == vim.diagnostic.severity.INFO then
						icon = " "
						hl_group = "DiagnosticInfo"
					elseif diagnostic.severity == vim.diagnostic.severity.HINT then
						icon = "󰌵 "
						hl_group = "DiagnosticHint"
					end

					vim.api.nvim_buf_set_extmark(bufnr, ns, diagnostic.lnum, 0, {
						virt_text = {{ icon, hl_group }},
						virt_text_pos = "right_align",
						priority = 10
					})
				end
			end

			-- highlight entire line for diagnostics
			for _, diagnostic in ipairs(diagnostics) do
				if diagnostic.lnum < line_count then
					local line = vim.api.nvim_buf_get_lines(bufnr, diagnostic.lnum, diagnostic.lnum + 1,
						false)[1] or ''
					local hl_group = 'DiagnosticLine' ..
					    vim.diagnostic.severity[diagnostic.severity]:sub(1, 1) ..
					    vim.diagnostic.severity[diagnostic.severity]:sub(2):lower()
					vim.api.nvim_buf_set_extmark(bufnr, ns, diagnostic.lnum, 0, {
						end_col = #line,
						hl_group = hl_group,
						hl_eol = true,
						priority = 5
					})
				end
			end
		end
	})
end

create_diagnostic_gutter()

