return {
    {
        -- Diff splitter/editor — used as a git/jujutsu difftool to select
        -- changes by file, hunk or individual line. Launch with :DiffEditor.
        "julienvincent/hunk.nvim",
        cmd = { "DiffEditor" },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("hunk").setup()
        end,
    },
}
