return {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    priority = 10,               -- Needs to be a really low priority, to catch others plugins keybindings.
    opts = {
        enabled = true,          -- overall on/off switch
        refresh_interval_ms = 8, -- how often the animation updates
        overwrite = {
            -- enable undo animations
            undo = {
                enabled = true,
                default_animation = {
                    name = "fade",
                    settings = {
                        from_color   = "DiffDelete",
                        max_duration = 500,
                        min_duration = 500,
                    },
                },
                undo_mapping = "u",
            },
            -- you can also enable redo if you like:
            redo = {
                enabled = false,
                default_animation = {
                    name = "fade",
                    settings = {
                        from_color   = "DiffAdd",
                        max_duration = 380,
                        min_duration = 300,
                    },
                },
                redo_mapping = "<c-r>",
            },
        },
    },
    config = function(_, opts)
        require("tiny-glimmer").setup(opts)
    end,
}
