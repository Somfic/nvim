local c = require("config")

return {
    -- Theme
    {
        "vague2k/vague.nvim",
        enabled = c.theme == "vague",
        lazy = false,
        priority = 1000,
        config = function()
            require("vague").setup({
                transparent = true,
                style = {
                    boolean = "none",
                    number = "none",
                    float = "none",
                    error = "none",
                    comments = "italic",
                    conditionals = "none",
                    functions = "none",
                    headings = "bold",
                    operators = "none",
                    strings = "none",
                    variables = "none",
                },
            })
            vim.cmd("colorscheme vague")
        end,
    },

    -- Icons
    { "nvim-tree/nvim-web-devicons" },
    { "echasnovski/mini.icons" },

    -- Which-key (keybinding hints)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                preset = "modern",
                delay = 500,
            })
        end,
    },
}
