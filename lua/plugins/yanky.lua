return {
    "gbprod/yanky.nvim",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
        { "p",  "<Plug>(YankyPutAfter)",   mode = { "n", "x" }, desc = "Paste after (yanky)" },
        { "P",  "<Plug>(YankyPutBefore)",  mode = { "n", "x" }, desc = "Paste before (yanky)" },
        { "gp", "<Plug>(YankyGPutAfter)",  mode = { "n", "x" }, desc = "Paste after & cursor end" },
        { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Paste before & cursor end" },
        { "<C-p>", "<Plug>(YankyPreviousEntry)", desc = "Yanky previous entry" },
        { "<C-n>", "<Plug>(YankyNextEntry)",     desc = "Yanky next entry" },
        {
            "<leader>p",
            function() Snacks.picker.yanky() end,
            desc = "Yank history",
        },
    },
    opts = {
        highlight = { timer = 200 },
    },
}
