return {
    -- Detects each file's actual indentation (tabs vs spaces + width) and sets
    -- the buffer's expandtab/shiftwidth/tabstop to match. This makes manual
    -- editing, LSP formatting (tabSize/insertSpaces) and conform (see
    -- conform.lua) all preserve the file's existing style instead of forcing
    -- the global 2-space default.
    "NMAC427/guess-indent.nvim",
    -- BufReadPre so the plugin's own BufReadPost autocmd is registered before
    -- the buffer is read and fires for it.
    event = { "BufReadPre", "BufNewFile" },
    cmd = "GuessIndent",
    opts = {},
}
