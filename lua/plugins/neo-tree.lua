return {
  "nvim-neo-tree/neo-tree.nvim",
  name = "neo tree",
  dependencies = { 
	'nvim-lua/plenary.nvim',
	'nvim-tree/nvim-web-devicons',
	'MunifTanjim/nui.nvim'
  },
  config = function ()
	vim.keymap.set('n', '<C-t>', ':Neotree filesystem reveal right<CR>')
  end
}