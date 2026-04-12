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

            vim.keymap.set("n", "<leader>gb", function()
                require("gitsigns").blame_line({ full = true })
            end, { desc = "Git blame line" })
            vim.keymap.set("n", "<leader>gB", function()
                require("gitsigns").toggle_current_line_blame()
            end, { desc = "Toggle inline blame" })
        end,
    },

    {
        -- Lazygit in a floating window — handles commit/push/pull/stash/etc.
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
            { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
        },
    },

    {
        -- Diff view
        "sindrets/diffview.nvim",
        config = function()
            require("diffview").setup()

            vim.keymap.set("n", "<leader>gD", "<cmd>DiffviewOpen<cr>", { desc = "Open diff view" })
            vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "File history" })
            vim.keymap.set("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current file history" })
        end,
    },
}
