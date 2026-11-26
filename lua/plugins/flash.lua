-- flash.nvim: jump to any visible spot with a search + label
return {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
        { "s",     function() require("flash").jump() end,              mode = { "n", "x", "o" }, desc = "Flash jump" },
        { "S",     function() require("flash").treesitter() end,        mode = { "n", "x", "o" }, desc = "Flash treesitter select" },
        { "r",     function() require("flash").remote() end,            mode = "o",               desc = "Remote flash" },
        { "R",     function() require("flash").treesitter_search() end, mode = { "o", "x" },      desc = "Treesitter search" },
        { "<C-s>", function() require("flash").toggle() end,            mode = "c",               desc = "Toggle flash in search" },
    },
}
