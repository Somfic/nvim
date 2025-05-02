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
					["-"] = false,
				},
				float = {
					padding = 0,
					max_width = 40,
					max_height = 20,
					win_options = {
						winblend = 0,
						relativenumber = false,
						number = false,
						signcolumn = "no",
						cursorline = false,
						cursorcolumn = false,
						foldcolumn = "0",
						list = false,
					},
				},
			})

			vim.keymap.set("n", "<leader>vf", oil.toggle_float, { desc = "files" })
			vim.keymap.set("n", "<BS>", oil.open, { desc = "Go to parent directory" })
			vim.keymap.set("n", "<ESC>", oil.close, { desc = "Close" })
			vim.keymap.set("n", "-", oil.toggle_float, { desc = "Close floating window" })
		end,
	},
}
