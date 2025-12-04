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
          hi HighlightUndo guibg=#444444 guifg=NONE
        ]])
    end,
}
