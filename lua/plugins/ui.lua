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

    {
        "tiagovla/tokyodark.nvim",
        enabled = c.theme == "tokyodark",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyodark").setup({
                transparent_background = true,
                gamma = 1.00,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = false },
                    identifiers = { italic = false },
                    functions = {},
                    variables = {},
                },
            })
            vim.cmd("colorscheme tokyodark")
        end,
    },

    -- Icons
    { "nvim-tree/nvim-web-devicons" },

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

    -- Bufferline (tabs at top)
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    separator_style = "thick",
                    always_show_bufferline = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    color_icons = true,
                    diagnostics = "nvim_lsp",
                    icon_pinned = "",
                    show_duplicate_prefix = false,
                    offsets = {
                        {
                            filetype = "oil",
                            text = "File Explorer",
                            text_align = "center",
                            separator = true,
                        },
                    },
                },
                highlights = {
                    buffer_selected = {
                        italic = false,
                    },
                    fill = {
                        bg = "none",
                    },
                },
            })
        end,
    },
}
