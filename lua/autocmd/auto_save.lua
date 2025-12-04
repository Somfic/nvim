-- auto format and save
vim.api.nvim_create_autocmd('InsertLeave', {
    pattern = '*',
    callback = function()
        -- only save if buffer is modifiable and has a filename
        if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
            -- format with LSP if available (suppress errors)
            pcall(function()
                vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
            end)

            -- save the file
            vim.cmd('silent! write')
        end
    end,
})
