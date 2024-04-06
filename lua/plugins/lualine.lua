return {
  "nvim-lualine/lualine.nvim",
  config = function ()
    require('lualine').setup({
     theme = 'dracula',
     tabline =  {
       lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_z = { 'location' },
     },
     sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {  },
      lualine_x = { },
      lualine_y = { },
      lualine_z = { }
     }
    })
  end
}
