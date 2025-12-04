return {
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true, -- use treesitter
                fast_wrap = {},
            })
        end,
    },

    {
        "windwp/nvim-ts-autotag",
        ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "xml" },
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },
};
