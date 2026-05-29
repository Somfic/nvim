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
o.shortmess:append('I') -- suppress intro message
o.shortmess:append('c') -- suppress completion messages
o.shortmess:append('s') -- suppress search wrap messages

-- behaviour
o.mouse = 'a'
o.clipboard = 'unnamedplus'
if os.getenv('WAYLAND_DISPLAY') then
    vim.g.clipboard = {
        name = 'wl-clipboard',
        copy = {
            ['+'] = 'wl-copy',
            ['*'] = 'wl-copy',
        },
        paste = {
            ['+'] = 'wl-paste --no-newline',
            ['*'] = 'wl-paste --no-newline',
        },
        cache_enabled = 0,
    }
end
o.undofile = true
o.swapfile = false
o.backup = false
o.shell = 'nu'
o.shellcmdflag = '-c'
o.shellquote = ''
o.shellxquote = ''

-- splits
o.splitright = true
o.splitbelow = true

-- peformance
o.updatetime = 250
o.timeoutlen = 400
