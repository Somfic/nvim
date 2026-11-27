-- LazyGit lives in snacks.lua (<leader>gg)
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
                -- deletions as the same bar, told apart by colour
                delete = { text = "│" },
                topdelete = { text = "│" },
                changedelete = { text = "│" },
                untracked = { text = "┆" },
            },
            current_line_blame = false,
            current_line_blame_opts = {
                delay = 300,
            },
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)

            -- Inline blame in the same italic comment colour as the usages above
            -- methods (lua/plugins/symbol-usage.lua); redone on every theme switch
            local function set_highlight()
                local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
                vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = comment.fg, italic = true })
            end
            set_highlight()
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("GitSignsBlameHighlight", { clear = true }),
                callback = set_highlight,
            })
        end,
    },
}
