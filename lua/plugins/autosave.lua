return {"Pocco81/auto-save.nvim",
	config = function()
		 require("auto-save").setup {
			-- your config goes here
			-- or just leave it empty :)
			condition = function(buf)
				vim.lsp.buf.format() -- format before saving
				return true
			end,
		 }
	end,}