return {
    "folke/persistence.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        local persistence = require("persistence")
        persistence.setup({
            options = { "buffers", "curdir", "tabpages", "winsize", "help" },
            pre_save = function()
                -- Don't persist transient DAP buffers (dap-repl, dap-terminal, dapui_*)
                local ok_dapui, dapui = pcall(require, "dapui")
                if ok_dapui then pcall(dapui.close) end
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_valid(buf) then
                        local ft = vim.bo[buf].filetype or ""
                        local name = vim.api.nvim_buf_get_name(buf)
                        local bt = vim.bo[buf].buftype or ""
                        local is_dap = ft:match("^dap")
                            or ft == "dap-repl"
                            or name:find("%[dap")
                            or name:find("%[DAP")
                            or (bt == "terminal" and name:find("dap"))
                        if is_dap then
                            pcall(vim.api.nvim_buf_delete, buf, { force = true })
                        end
                    end
                end
            end,
        })

        vim.keymap.set("n", "<leader>ss", function()
            persistence.load()
        end, { desc = "Restore session for cwd" })

        vim.keymap.set("n", "<leader>sl", function()
            persistence.load({ last = true })
        end, { desc = "Restore last session" })

        vim.keymap.set("n", "<leader>sd", function()
            persistence.stop()
        end, { desc = "Stop saving session" })

        -- Auto-restore session if nvim was launched with no args and a session exists.
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("PersistenceAutoLoad", { clear = true }),
            nested = true,
            callback = function()
                if vim.fn.argc(-1) ~= 0 then
                    return
                end
                persistence.load()
                -- Defensive: strip any DAP buffers that snuck into an older session file
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_valid(buf) then
                        local ft = vim.bo[buf].filetype or ""
                        local name = vim.api.nvim_buf_get_name(buf)
                        if ft:match("^dap") or name:find("%[dap") or name:find("%[DAP") then
                            pcall(vim.api.nvim_buf_delete, buf, { force = true })
                        end
                    end
                end
                local listed = vim.tbl_filter(function(buf)
                    return vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= ""
                end, vim.api.nvim_list_bufs())
                if #listed > 0 then
                    vim.g.session_loaded = true
                end
            end,
        })
    end,
}
