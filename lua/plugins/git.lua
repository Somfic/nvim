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

    -- {
    --     -- GitLab MR reviews
    --     "harrisoncramer/gitlab.nvim",
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --         "nvim-lua/plenary.nvim",
    --         "sindrets/diffview.nvim",
    --         "stevearc/dressing.nvim",
    --     },
    --     build = function()
    --         require("gitlab.server").build(true)
    --     end,
    --     keys = {
    --         { "<leader>mm", function() require("gitlab").choose_merge_request() end, desc = "Browse MRs" },
    --         { "<leader>mr", function() require("gitlab").review() end, desc = "Review MR" },
    --         { "<leader>ms", function() require("gitlab").summary() end, desc = "MR summary" },
    --         { "<leader>ma", function() require("gitlab").approve() end, desc = "Approve MR" },
    --         { "<leader>mR", function() require("gitlab").revoke() end, desc = "Revoke approval" },
    --         { "<leader>mc", function() require("gitlab").create_comment() end, desc = "Create comment" },
    --         { "<leader>mn", function() require("gitlab").create_note() end, desc = "Create note" },
    --         { "<leader>md", function() require("gitlab").toggle_discussions() end, desc = "Toggle discussions" },
    --         { "<leader>mp", function() require("gitlab").pipeline() end, desc = "Pipeline" },
    --         { "<leader>mM", function() require("gitlab").merge() end, desc = "Merge MR" },
    --         { "<leader>mo", function() require("gitlab").open_in_browser() end, desc = "Open in browser" },
    --     },
    --     config = function()
    --         require("gitlab").setup()
    --     end,
    -- },

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
