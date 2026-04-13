-- Typo-tolerant uppercase aliases for the common quit/write commands.
-- All forward the bang, so :Q!, :Wq!, :QW!, etc. work too.

local function alias(name, target)
    vim.api.nvim_create_user_command(name, target .. "<bang>", { bang = true })
end

alias("Q",  "q")
alias("W",  "w")
alias("Wq", "wq")
alias("WQ", "wq")
alias("Qw", "wq")
alias("QW", "wq")
