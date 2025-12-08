return {
    "tzachar/highlight-undo.nvim",
    config = function()
        require("highlight-undo").setup({
            duration = 300,
            undo = {
                hlgroup = "HighlightUndo",
                mode = "n",
                lhs = "u",
                map = "undo",
                opts = {},
            },
            redo = {
                hlgroup = "HighlightUndo",
                mode = "n",
                lhs = "<C-r>",
                map = "redo",
                opts = {},
            },
            highlight_for_count = true,
        })

        -- Set the highlight color
        vim.cmd([[
          hi HighlightUndo guibg=#ff9e64 guifg=#1a1b26 gui=bold
        ]])
    end,
}
