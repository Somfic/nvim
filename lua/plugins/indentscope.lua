return {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("mini.indentscope").setup({
            symbol = "│",
            options = { try_as_border = true },
            draw = {
                animation = require("mini.indentscope").gen_animation.quadratic({
                    easing = "out",
                    duration = 80,
                    unit = "total",
                }),
            },
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "help",
                "lazy",
                "mason",
                "notify",
                "oil",
                "TelescopePrompt",
                "TelescopeResults",
                "trouble",
                "checkhealth",
                "man",
                "lspinfo",
                "noice",
                "fidget",
                "qf",
            },
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
        })
    end,
}
