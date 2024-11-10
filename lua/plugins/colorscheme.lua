return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
      })
      vim.cmd.colorscheme "catppuccin"
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    name = "treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require('nvim-treesitter.configs')

      config.setup({
        sync_install = false,
        autoinstall = true,
        highlight = { enable = true, additional_vim_regex_highlighting = true },
        indent = { enable = true },

      })
    end
  },
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require 'colorizer'.setup({
        'css',
        'scss',
        'javascript',
        'typescript',
        'html',
        'vim',
        'lua',
        'json',
        'yaml',
        'toml',
        'markdown',
        'sh',
        'dockerfile',
        'plaintext',
        'svelte',
      })
    end,
  }
}
