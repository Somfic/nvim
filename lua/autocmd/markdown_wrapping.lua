vim.api.nvim_create_autocmd('BufWinEnter', {
  pattern = { '*.md' },
  callback = function()
    vim.opt_local.colorcolumn = ''
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
  pattern = { '*.md' },
  callback = function()
    vim.opt.colorcolumn = '120'
    vim.opt.textwidth = 120
  end,
})
