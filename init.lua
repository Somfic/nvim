local c = require('config')

require('options')
require('keybindings')

require('autocmd.auto_save')
require('autocmd.auto_create_directory')
require('autocmd.highlight_yank')

-- setup lazyvim
local lazy = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazy,
    })
end
vim.opt.rtp:prepend(lazy)

require("lazy").setup("plugins", {
    ui = { border = "rounded" },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
