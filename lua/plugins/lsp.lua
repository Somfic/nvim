return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true
    }
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      {
        "williamboman/mason-lspconfig.nvim",
        opt = { automatic_installation = true, }
      }
    },
    config = function()
      local lspconfig = require('lspconfig')
      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.csharp_ls.setup({})
      lspconfig.svelte.setup({})
      lspconfig.rust_analyzer.setup({})

      vim.keymap.set('n', '<C-.>', vim.lsp.buf.code_action, {})
    end
  },
  {
    "nvim-lua/lsp-status.nvim",
    lazy = false,
    config = function()
      require('lsp-status').register_progress()
    end
  }
}
