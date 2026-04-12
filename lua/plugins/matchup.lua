return {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
        vim.g.matchup_matchparen_deferred = 1
    end,
}
