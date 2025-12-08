return {
    {
        "echasnovski/mini.animate",
        version = false,
        config = function()
            require("mini.animate").setup({
                cursor = {
                    enable = true,
                    timing = require("mini.animate").gen_timing.exponential({
                        easing = "out",
                        duration = 120,
                        unit = "total"
                    }),
                    path = require("mini.animate").gen_path.line({
                        predicate = function() return true end,
                    }),
                },
                scroll = {
                    enable = true,
                    timing = require("mini.animate").gen_timing.exponential({
                        easing = "out",
                        duration = 150,
                        unit = "total"
                    }),
                },
                resize = {
                    enable = false,
                },
                open = {
                    enable = false,
                },
                close = {
                    enable = false,
                },
            })
        end,
    },
}
