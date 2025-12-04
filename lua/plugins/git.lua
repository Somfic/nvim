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
        end,
    },

    {
        -- Git commands helper
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local neogit = require("neogit")

            neogit.setup({
                integrations = {
                    telescope = true,
                    diffview = true,
                },
            })

            -- Keymaps
            vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit status" })
            vim.keymap.set("n", "<leader>gc", "<cmd>Neogit commit<cr>", { desc = "Git commit" })
            vim.keymap.set("n", "<leader>gP", "<cmd>Neogit push<cr>", { desc = "Git push" })
            vim.keymap.set("n", "<leader>gp", "<cmd>Neogit pull<cr>", { desc = "Git pull" })
            vim.keymap.set("n", "<leader>gb", function()
                require("gitsigns").blame_line({ full = true })
            end, { desc = "Git blame line" })
            vim.keymap.set("n", "<leader>gB", function()
                require("gitsigns").toggle_current_line_blame()
            end, { desc = "Toggle inline blame" })

            -- Simple commit workflow (with prompt)
            vim.keymap.set("n", "<leader>gC", function()
                local msg = vim.fn.input("Commit message: ")
                if msg ~= "" then
                    vim.cmd(string.format('!git add . && git commit -m "%s"', msg))
                    vim.notify("Committed all changes", vim.log.levels.INFO)
                end
            end, { desc = "Stage all & commit" })

            -- Quick commit and push workflow
            vim.keymap.set("n", "<leader>gQ", function()
                local msg = vim.fn.input("Commit message: ")
                if msg ~= "" then
                    vim.cmd(string.format('!git add . && git commit -m "%s" && git push', msg))
                    vim.notify("Committed and pushed!", vim.log.levels.INFO)
                end
            end, { desc = "Quick commit & push" })
        end,
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
