vim.pack.add({
    { src = 'https://github.com/folke/which-key.nvim' },
})

local wk = require('which-key')

wk.setup({
    plugins = {
        spelling = {
            enabled = true,
            suggestions = 20,
        },
    },
})

wk.add({ "<leader>f", group = "find" })
