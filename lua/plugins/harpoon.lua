return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        vim.keymap.set("n", "<leader>ha", function()
            harpoon:list():add()
        end, { desc = "Harpoon add" })

        vim.keymap.set("n", "<leader>hr", function()
            harpoon:list():remove()
        end, { desc = "Harpoon remove" })

        vim.keymap.set("n", "<leader>hh", function()
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, { desc = "Harpoon menu" })

        for i = 1, 9 do
            vim.keymap.set("n", "<leader>" .. i, function()
                harpoon:list():select(i)
            end, { desc = "Harpoon slot " .. i })
        end

        -- Re-sort + redraw bufferline whenever harpoon list changes so pinned
        -- buffers move to the front and slot numbers stay in sync.
        local function refresh_bufferline()
            vim.schedule(function()
                local ok, bufferline = pcall(require, "bufferline")
                if ok and _G.bufferline_harpoon_sort then
                    bufferline.sort_by(_G.bufferline_harpoon_sort)
                end
                vim.cmd("redrawtabline")
            end)
        end

        harpoon:extend({
            ADD = refresh_bufferline,
            REMOVE = refresh_bufferline,
            REORDER = refresh_bufferline,
        })
    end,
}
