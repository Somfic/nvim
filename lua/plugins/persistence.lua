return {
    "folke/persistence.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        local persistence = require("persistence")
        persistence.setup({
            options = { "buffers", "curdir", "tabpages", "winsize", "help" },
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
