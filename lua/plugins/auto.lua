return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup({
                check_ts = true, -- use treesitter
                fast_wrap = {},
            })

            -- Map tab to jump out of pairs
            local function jump_out_of_pair()
                local line = vim.api.nvim_get_current_line()
                local col = vim.api.nvim_win_get_cursor(0)[2]
                local char = line:sub(col + 1, col + 1)

                -- Check if next char is a closing bracket/paren/quote
                if char:match('[%)%]%}"\']') then
                    return "<Right>"
                else
                    return "<Tab>"
                end
            end

            vim.keymap.set("i", "<Tab>", function()
                return jump_out_of_pair()
            end, { expr = true, noremap = true })
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "xml", "svelte" },
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },

    {
        "numToStr/Comment.nvim",
        keys = {
            { "gcc", mode = "n", desc = "Toggle comment" },
            { "gc", mode = { "n", "v" }, desc = "Toggle comment" },
        },
        config = function()
            require("Comment").setup()
        end,
    },

    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },
};
