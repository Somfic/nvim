return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        vim.keymap.set("n", "<leader>ha", function()
            harpoon:list():add()
        end, { desc = "Harpoon add file" })

        vim.keymap.set("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon menu" })

        vim.keymap.set("n", "<leader>hp", function()
            harpoon:list():prev()
        end, { desc = "Harpoon prev" })

        vim.keymap.set("n", "<leader>hn", function()
            harpoon:list():next()
        end, { desc = "Harpoon next" })

        for i = 1, 4 do
            vim.keymap.set("n", "<leader>" .. i, function()
                harpoon:list():select(i)
            end, { desc = "Harpoon slot " .. i })
        end
    end,
}
