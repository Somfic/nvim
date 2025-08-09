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
		prefix = "●", -- could be '●', '▎', 'x'
		spacing = 2,
		format = function(diagnostic)
			-- truncate long messages
			local message = diagnostic.message
			if #message > 60 then
				message = message:sub(1, 57) .. "..."
			end
			return message
		end,
	},
	signs = true,
	update_in_insert = false,
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