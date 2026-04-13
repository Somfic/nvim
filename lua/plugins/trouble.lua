return {
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {
      auto_close = true,
      focus = true,
      modes = {
        diagnostics = {
          format = "{severity_icon} {message:md} {code:code}{pos}",
        },
      },
    },
    config = function(_, opts)
      require("trouble").setup(opts)
      local function fix_hl()
        local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
        vim.api.nvim_set_hl(0, "TroubleCount", { fg = comment.fg, italic = true })
      end
      fix_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = fix_hl })
    end,
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xd",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer diagnostics",
      },
      {
        "<leader>xs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>xl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location list",
      },
      {
        "<leader>xq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix list",
      },
    },
  },
}
