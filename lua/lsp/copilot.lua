-- GitHub Copilot configuration

-- Copilot keybindings
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

-- Custom keymaps for Copilot
vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
  desc = 'Accept Copilot suggestion'
})

vim.keymap.set('i', '<C-l>', '<Plug>(copilot-accept-word)', {
  desc = 'Accept Copilot word'
})

vim.keymap.set('i', '<C-;>', '<Plug>(copilot-next)', {
  desc = 'Next Copilot suggestion'
})

vim.keymap.set('i', '<C-,>', '<Plug>(copilot-previous)', {
  desc = 'Previous Copilot suggestion'
})

-- Dismiss Copilot suggestion
vim.keymap.set('i', '<C-e>', '<Plug>(copilot-dismiss)', {
  desc = 'Dismiss Copilot suggestion'
})

-- Enable Copilot for specific filetypes
vim.g.copilot_filetypes = {
  ['*'] = true,
  gitcommit = false,
  gitrebase = false,
  help = false,
  markdown = true,
  yaml = true,
  json = true,
}

-- Copilot settings
vim.g.copilot_workspace_folders = { vim.fn.getcwd() }

-- Configure Copilot to work with nvim-cmp
local copilot_cmp_comparators = require('cmp').config.compare
copilot_cmp_comparators.copilot = function(entry1, entry2)
  if entry1.source.name == 'copilot' and entry2.source.name ~= 'copilot' then
    return true
  elseif entry1.source.name ~= 'copilot' and entry2.source.name == 'copilot' then
    return false
  end
  return nil
end

-- Auto-start Copilot when opening supported files
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    vim.cmd('Copilot setup')
  end
)
