local c = require("config")

return {
  {
    "nvim-lualine/lualine.nvim",
    enabled = c.statusline,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto", -- matches your colorscheme
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true, -- single statusline for all windows
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } }, -- relative path
          lualine_x = { "filetype" },
          lualine_y = {},
          lualine_z = {
            {
              function()
                return os.date("%H:%M")
              end,
              icon = "",
            },
          },
        },
      })
    end,
  },
}
