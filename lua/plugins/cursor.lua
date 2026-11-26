-- Cursor animation only; smooth scrolling is snacks.scroll (snacks.lua)
return {
    {
        "echasnovski/mini.animate",
        version = false,
        event = "VeryLazy",
        config = function()
            local animate = require("mini.animate")
            animate.setup({
                cursor = {
                    enable = true,
                    timing = animate.gen_timing.exponential({
                        easing = "out",
                        duration = 120,
                        unit = "total",
                    }),
                    path = animate.gen_path.line({
                        predicate = function()
                            return vim.bo.filetype ~= "oil"
                        end,
                    }),
                },
                scroll = { enable = false },
                resize = { enable = false },
                open = { enable = false },
                close = { enable = false },
            })
        end,
    },
}
