return {
    {
        -- Git signs in gutter
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
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
            })

            vim.keymap.set("n", "<leader>ub", function()
                require("gitsigns").toggle_current_line_blame()
            end, { desc = "Toggle inline blame" })
        end,
    },

    {
        -- Lazygit in a floating window — handles commit/push/pull/stash/diff/history.
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>c", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },
}
