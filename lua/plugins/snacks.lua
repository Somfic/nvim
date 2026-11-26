-- snacks.nvim: notifications, vim.ui.input, indent guides, smooth scroll, lazygit, terminals
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        { "<leader>c", function() Snacks.lazygit() end, desc = "LazyGit" },
        { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification history" },
    },
    opts = {
        bigfile = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
            style = "compact",
            top_down = true,
        },
        input = { enabled = true },
        indent = {
            enabled = true,
            indent = { enabled = false }, -- only the current scope, like mini.indentscope
            scope = { enabled = true, char = "│" },
            animate = { duration = { step = 10, total = 80 } },
            filter = function(buf)
                return vim.bo[buf].buftype == "" and vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false
            end,
        },
        scroll = {
            enabled = true,
            animate = { duration = { step = 15, total = 150 }, easing = "outQuad" },
        },
        lazygit = { enabled = true },
        terminal = { enabled = true },
        styles = {
            notification = { border = "rounded" },
            input = { border = "rounded" },
        },
    },
}
