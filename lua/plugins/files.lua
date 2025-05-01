return {
	{
		"stevearc/oil.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		lazy = false,
		config = function()
			local oil = require("oil")

			oil.setup({
				default_file_explorer = true,
				columns = {
					"icon",
				},
				keymaps = {
					["-"] = false, -- Disable default keymap for '-'
				},
			})

			vim.keymap.set("n", "<BS>", oil.open, { desc = "Go to parent directory" })
			vim.keymap.set("n", "-", oil.toggle_float	, { desc = "Close floating window" })
		end,
	},
}
