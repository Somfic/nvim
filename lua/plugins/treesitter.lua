return {
  "nvim-treesitter/nvim-treesitter",
  name = "treesitter",
  build = ":TSUpdate",
  config = function ()
	local config = require('nvim-treesitter.configs')

	config.setup({
	autoinstall = true,
	highlight = { enable = true },
	indent = { enable = true }
	})
  end
}
