return {
    "gbprod/yanky.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        require("yanky").setup({
            highlight = { timer = 200 },
        })
        require("telescope").load_extension("yank_history")

        local map = vim.keymap.set

        map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Paste after (yanky)" })
        map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Paste before (yanky)" })
        map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Paste after & cursor end" })
        map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Paste before & cursor end" })

        map("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "Yanky previous entry" })
        map("n", "<C-n>", "<Plug>(YankyNextEntry)", { desc = "Yanky next entry" })

        map("n", "<leader>p", "<cmd>Telescope yank_history<cr>", { desc = "Yank history" })
    end,
}
