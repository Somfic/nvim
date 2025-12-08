return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua",
                    "vim",
                    "vimdoc",
                    "javascript",
                    "typescript",
                    "tsx",
                    "json",
                    "html",
                    "css",
                    "scss",
                    "svelte",
                    "rust",
                    "python",
                    "go",
                    "markdown",
                    "markdown_inline",
                },
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<CR>",
                        node_incremental = "<CR>",
                        scope_incremental = "<S-CR>",
                        node_decremental = "<BS>",
                    },
                },
            })
        end,
    },
}
