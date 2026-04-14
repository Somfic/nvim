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
                "dap-repl",
                "dap-float",
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "dapui_console",
            },
            callback = function()
                vim.b.miniindentscope_disable = true
            end,
        })

        -- dap widget floating buffers have no filetype — disable by buffer name pattern
        vim.api.nvim_create_autocmd("BufWinEnter", {
            callback = function(args)
                local name = vim.api.nvim_buf_get_name(args.buf)
                if name:find("%[dap") or name:find("DAP") then
                    vim.b[args.buf].miniindentscope_disable = true
                end
            end,
        })
    end,
}
