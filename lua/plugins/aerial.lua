return {
    {
        "stevearc/aerial.nvim",
        event = "LspAttach",
        keys = {
            { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Toggle outline" },
        },
        opts = {
            layout = { default_direction = "right", min_width = 30 },
            backends = { "lsp", "treesitter", "markdown" },
            filter_kind = false,
            show_guides = true,
        },
    },
}
