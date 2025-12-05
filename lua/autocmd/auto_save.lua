-- auto format and save
vim.api.nvim_create_autocmd('InsertLeave', {
    pattern = '*',
    callback = function()
        -- only save if buffer is modifiable and has a filename
        if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
            -- skip formatting for Java (use project build tools instead)
            local ft = vim.bo.filetype
            if ft ~= "java" then
                -- format with LSP if available (suppress errors)
                pcall(function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local clients = vim.lsp.get_clients({ bufnr = bufnr })
                    local has_eslint = false
                    for _, c in ipairs(clients) do
                        if c.name == "eslint" then
                            has_eslint = true
                            break
                        end
                    end

                    if has_eslint then
                        vim.lsp.buf.format({
                            async = false,
                            timeout_ms = 1000,
                            filter = function(client)
                                return client.name == "eslint"
                            end
                        })
                    else
                        vim.lsp.buf.format({ async = false, timeout_ms = 1000 })
                    end
                end)
            end

            -- save the file
            vim.cmd('silent! write')
        end
    end,
})
