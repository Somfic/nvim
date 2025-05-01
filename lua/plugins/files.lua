return {
	{
		"stevearc/oil.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		lazy = false,
		keys = {
			{ "<leader>vf", ":Oil --float<CR>", desc = "files" },
		},
		config = function()
			require("oil").setup({
				default_file_explorer = true,
				columns = {
					"icon",
				},
			})
		end,
	},
}
