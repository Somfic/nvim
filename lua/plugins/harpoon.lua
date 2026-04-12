return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local harpoon = require("harpoon")
        harpoon:setup()

        vim.keymap.set("n", "<leader>bp", function()
            harpoon:list():add()
        end, { desc = "Pin buffer" })

        for i = 1, 9 do
            vim.keymap.set("n", "<leader>bp" .. i, function()
                harpoon:list():replace_at(i)
            end, { desc = "Pin buffer to slot " .. i })

            vim.keymap.set("n", "<leader>" .. i, function()
                harpoon:list():select(i)
            end, { desc = "Harpoon slot " .. i })
        end

        -- Collapse the 9 slot-jump entries in which-key into one display row.
        local wk_ok, wk = pcall(require, "which-key")
        if wk_ok then
            local entries = { { "<leader>1", desc = "Jump pinned buffer 1..9" } }
            for i = 2, 9 do
                table.insert(entries, { "<leader>" .. i, hidden = true })
            end
            -- Same treatment for the bp1..bp9 family.
            table.insert(entries, { "<leader>bp1", desc = "Pin buffer to slot 1..9" })
            for i = 2, 9 do
                table.insert(entries, { "<leader>bp" .. i, hidden = true })
            end
            wk.add(entries)
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
