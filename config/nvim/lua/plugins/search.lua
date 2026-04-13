return {
    {
        "kevinhwang91/nvim-hlslens",
        config = function()
            require("hlslens").setup({
                calm_down = true,
                nearest_only = true,
            })

            -- Keymaps for search with lens
            local map = vim.keymap.set

            map("n", "n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
                { desc = "Next search result" })
            map("n", "N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
                { desc = "Prev search result" })

            map("n", "*", [[*<Cmd>lua require('hlslens').start()<CR>]], { desc = "Search word under cursor" })
            map("n", "#", [[#<Cmd>lua require('hlslens').start()<CR>]], { desc = "Search word backward" })

            -- Clear search highlight on escape
            map("n", "<Esc>", "<Cmd>noh<CR>", { desc = "Clear search" })
        end,
    },
}
