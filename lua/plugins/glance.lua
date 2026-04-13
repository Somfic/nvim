return {
    {
        "dnlhc/glance.nvim",
        cmd = "Glance",
        keys = {
            { "<leader>gpd", "<cmd>Glance definitions<cr>",      desc = "Peek definitions" },
            { "<leader>gpu", "<cmd>Glance references<cr>",       desc = "Peek usages" },
            { "<leader>gpi", "<cmd>Glance implementations<cr>",  desc = "Peek implementations" },
            { "<leader>gpt", "<cmd>Glance type_definitions<cr>", desc = "Peek type definitions" },
        },
        opts = {
            border = { enable = true },
            hooks = {
                before_open = function(results, open, jump)
                    if #results == 1 then
                        jump(results[1])
                    else
                        open(results)
                    end
                end,
            },
        },
    },
}
