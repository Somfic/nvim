return {
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        "*",
      }, {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
      })

      -- Disable colorizer in telescope
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "TelescopeResults",
        callback = function()
          require("colorizer").detach_from_buffer(0)
        end,
      })
    end,
  },
}
