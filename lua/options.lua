local o = vim.opt

-- line numbers (shown in statusline instead)
o.number = false
o.relativenumber = false

-- indentation
o.tabstop = 3
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true

-- search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true

-- ui
o.fillchars = { eob = ' ' }
o.termguicolors = true

o.signcolumn = 'yes'
o.cursorline = true
o.scrolloff = 8
o.wrap = false
o.hlsearch = true
o.ruler = false
o.showcmd = false
o.showmode = false
o.cmdheight = 0

-- behaviour
o.mouse = 'a'
o.clipboard = 'unnamedplus'
o.undofile = true
o.swapfile = false
o.backup = false

-- splits
o.splitright = true
o.splitbelow = true

-- peformance
o.updatetime = 250
o.timeoutlen = 300
