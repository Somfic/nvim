-- Define the mapping from ANSI codes to Vim highlight groups
local ansi_to_hl = {
  ["\27[0m"]    = '%#Normal#',
  ["\27[1;30m"] = '%#AnsiBlack#',
  ["\27[1;31m"] = '%#AnsiRed#',
  ["\27[1;32m"] = '%#AnsiGreen#',
  ["\27[1;33m"] = '%#AnsiYellow#',
  ["\27[1;34m"] = '%#AnsiBlue#',
  ["\27[1;35m"] = '%#AnsiMagenta#',
  ["\27[1;36m"] = '%#AnsiCyan#',
  ["\27[1;37m"] = '%#AnsiWhite#',
  -- Add more mappings if needed
}

-- Define the Vim highlight groups for the ANSI colors
vim.api.nvim_exec([[
  highlight AnsiBlack   guifg=#000000
  highlight AnsiRed     guifg=#ff5555
  highlight AnsiGreen   guifg=#50fa7b
  highlight AnsiYellow  guifg=#f1fa8c
  highlight AnsiBlue    guifg=#bd93f9
  highlight AnsiMagenta guifg=#ff79c6
  highlight AnsiCyan    guifg=#8be9fd
  highlight AnsiWhite   guifg=#f8f8f2
]], false)

-- Modify the prompt function to parse ANSI codes
local function prompt(cmd)
  local output = vim.fn.system(cmd)
  local result = ''
  local pos = 1
  local length = #output

  while pos <= length do
    local start, finish, esc_seq = output:find('(\27%[[0-9;]*m)', pos)
    if start then
      -- Append text before the escape sequence
      if start > pos then
        result = result .. output:sub(pos, start - 1)
      end
      -- Get the corresponding highlight group
      local hl_group = ansi_to_hl[esc_seq] or ''
      result = result .. hl_group
      pos = finish + 1
    else
      -- Append the rest of the string
      result = result .. output:sub(pos)
      break
    end
  end
  return result
end

-- Your lualine configuration
return {
  "nvim-lualine/lualine.nvim",
  config = function()
    require('lualine').setup({
      options = {
        icons_enabled = true,
        component_separators = '',
        section_separators = '',
        globalstatus = true,
      },
      tabline = {
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      sections = {}
    })
  end
}
