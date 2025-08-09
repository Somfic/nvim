-- diagnostics
vim.diagnostic.config({
	update_in_insert = true,
	severity_sort = true,
	signs = true,
	underline = false,
	virtual_text = {
		spacing = 4,
		prefix = '●',
	},
})

-- highlight entire line with error
vim.api.nvim_set_hl(0, 'DiagnosticLineError', { bg = '#3f1a1a' })
vim.api.nvim_set_hl(0, 'DiagnosticLineWarn', { bg = '#3f3a1a' })
vim.api.nvim_set_hl(0, 'DiagnosticLineInfo', { bg = '#1a1a3f' })
vim.api.nvim_set_hl(0, 'DiagnosticLineHint', { bg = '#1a3f1a' })

-- highlight entire line for diagnostics
vim.api.nvim_create_autocmd({ 'DiagnosticChanged' }, {
	callback = function(args)
		local bufnr = args.buf
		if not vim.api.nvim_buf_is_valid(bufnr) then return end

		local ns = vim.api.nvim_create_namespace('diagnostic_line_hl')
		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

		local diagnostics = vim.diagnostic.get(bufnr)
		local line_count = vim.api.nvim_buf_line_count(bufnr)

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
				})
			end
		end
	end
})

