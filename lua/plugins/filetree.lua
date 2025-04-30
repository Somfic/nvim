return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	cmd = "NvimTreeToggle",
	keys = {
		{ "<leader>vf", ":NvimTreeToggle<CR>", desc = "Toggle file explorer (view files)" },
	},
	config = function()
		require("nvim-tree").setup({
			actions = {
				open_file = {
					-- Align on the right side
					quit_on_open = true, -- Close the tree when opening a file
					resize_window = true, -- Resize the window to fit the file

					window_picker = {
						enable = false, -- Ensures it replaces the current buffer
					},
				},
			},
		})
	end,
}
