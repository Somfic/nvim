local config = require("config")

return {
    {
        "j-hui/fidget.nvim",
        enabled = config.lsp,
        config = function()
            require("fidget").setup({
                progress = {
                    poll_rate = 0.5,
                    suppress_on_insert = false,
                    ignore_done_already = false,
                    ignore_empty_message = false,
                    display = {
                        render_limit = 16,
                        done_ttl = 3,
                        done_icon = "✔",
                        done_style = "Constant",
                        progress_ttl = math.huge,
                        progress_icon = { pattern = "dots", period = 1 },
                        progress_style = "WarningMsg",
                        group_style = "Title",
                        icon_style = "Question",
                        priority = 30,
                        skip_history = true,
                        format_message = function(msg)
                            return msg.message
                        end,
                        format_annote = function(msg)
                            return msg.title
                        end,
                        format_group_name = function(group)
                            return tostring(group)
                        end,
                        overrides = {
                            rust_analyzer = { name = "rust-analyzer" },
                        },
                    },
                    lsp = {
                        progress_ringbuf_size = 0,
                    },
                },
                notification = {
                    poll_rate = 10,
                    filter = vim.log.levels.INFO,
                    override_vim_notify = false,
                    configs = { default = require("fidget.notification").default_config },
                    window = {
                        normal_hl = "Comment",
                        winblend = 0,
                        border = "rounded",
                        zindex = 45,
                        max_width = 0,
                        max_height = 0,
                        x_padding = 1,
                        y_padding = 0,
                        align = "bottom",
                        relative = "editor",
                    },
                },
            })
        end,
    },
}
