return {
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    progress = {
                        enabled = false,
                    },
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                presets = {
                    bottom_search = true,         -- use bottom for search
                    command_palette = true,       -- command palette
                    long_message_to_split = true, -- long messages go to split
                    inc_rename = false,
                    lsp_doc_border = true,
                },
            })
        end,
    },
}
