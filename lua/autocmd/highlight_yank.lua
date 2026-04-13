-- highlight on yank with animation
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
    callback = function()
        pcall(function()
            vim.highlight.on_yank({
                higroup = 'Search',
                timeout = 700,
            })
        end)
    end,
})
