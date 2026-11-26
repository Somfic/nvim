return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        opts = {
            -- vim.notify is handled by snacks.notifier
            notify = { enabled = false },
            lsp = {
                progress = {
                    enabled = false,
                },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
            presets = {
                bottom_search = true,         -- use bottom for search
                command_palette = true,       -- command palette
                long_message_to_split = true, -- long messages go to split
                inc_rename = false,
                lsp_doc_border = true,
            },
        },
    },
}
