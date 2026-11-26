-- LazyGit lives in snacks.lua (<leader>c)
return {
    {
        -- Git signs in gutter
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>ub", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle inline blame" },
        },
        opts = {
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "┆" },
            },
            current_line_blame = false,
            current_line_blame_opts = {
                delay = 300,
            },
        },
    },
}
