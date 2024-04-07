return {
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
