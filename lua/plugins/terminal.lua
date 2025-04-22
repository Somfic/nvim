return {
    "akinsho/toggleterm.nvim",
    config = function()
        require("toggleterm").setup({
            open_mapping = [[<leader>vt]], -- Shortcut for opening the terminal
            direction = "horizontal",      -- Open terminal at the bottom
            shell = "nu",                  -- Set Nushell as the default shell
        })
    end,
}
