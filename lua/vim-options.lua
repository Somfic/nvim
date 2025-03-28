vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set smartindent")
vim.cmd("set smarttab")
vim.cmd("set autoindent")
vim.cmd("set smartcase")
vim.cmd("set ignorecase")
vim.cmd("set nowrap")
vim.cmd("set number")

vim.opt.number = false
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- language
vim.cmd("language en_GB")

-- show diagonstics in insert mode
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    update_in_insert = true,
  }
)
