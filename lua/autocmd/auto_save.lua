-- auto format and save
local function auto_format_and_save()
    -- only save if buffer is modifiable and has a filename
    if vim.bo.modifiable and vim.fn.expand('%') ~= '' then
        -- skip formatting for Java (use project build tools instead)
        local ft = vim.bo.filetype
        if ft ~= "java" then
            -- format with LSP if available (suppress errors)
            local bufnr = vim.api.nvim_get_current_buf()
            local clients = vim.lsp.get_clients({ bufnr = bufnr })
            local has_eslint = false
            local has_formatter = false

            for _, c in ipairs(clients) do
                if c.name == "eslint" then
                    has_eslint = true
                    has_formatter = true
                    break
                end
                if c.server_capabilities.documentFormattingProvider then
                    has_formatter = true
                end
            end

            if has_formatter then
                pcall(function()
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
        end

        -- save the file
        vim.cmd('silent! write')
    end
end

-- trigger on insert leave and text changes in normal mode
vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
    pattern = '*',
    callback = auto_format_and_save,
})
