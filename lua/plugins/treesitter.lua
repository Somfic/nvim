return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
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
                    "c",
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
                matchup = {
                    enable = true,
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = { query = "@function.outer", desc = "around function" },
                            ["if"] = { query = "@function.inner", desc = "inside function" },
                            ["ac"] = { query = "@class.outer", desc = "around class" },
                            ["ic"] = { query = "@class.inner", desc = "inside class" },
                            ["aa"] = { query = "@parameter.outer", desc = "around argument" },
                            ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
                            ["al"] = { query = "@loop.outer", desc = "around loop" },
                            ["il"] = { query = "@loop.inner", desc = "inside loop" },
                            ["ai"] = { query = "@conditional.outer", desc = "around conditional" },
                            ["ii"] = { query = "@conditional.inner", desc = "inside conditional" },
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]f"] = { query = "@function.outer", desc = "next function" },
                            ["]c"] = { query = "@class.outer", desc = "next class" },
                        },
                        goto_previous_start = {
                            ["[f"] = { query = "@function.outer", desc = "prev function" },
                            ["[c"] = { query = "@class.outer", desc = "prev class" },
                        },
                    },
                },
            })
        end,
    },
}
