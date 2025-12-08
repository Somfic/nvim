local c = require("config")

return {
    -- Mason (LSP installer)
    {
        "williamboman/mason.nvim",
        enabled = c.lsp,
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })
        end,
    },

    -- Mason LSP config bridge
    {
        "williamboman/mason-lspconfig.nvim",
        enabled = c.lsp,
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",        -- Lua
                    "ts_ls",         -- TypeScript/JavaScript
                    "svelte",        -- Svelte
                    "rust_analyzer", -- Rust
                    "eslint",        -- ESLint
                    "jdtls",         -- Java
                },
                automatic_installation = true,
            })
        end,
    },

    -- Mason tool installer (formatters, linters, etc.)
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        enabled = c.lsp,
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-tool-installer").setup({
                ensure_installed = {
                    "stylua", -- Lua formatter
                },
                auto_update = false,
                run_on_start = true,
            })
        end,
    },

    -- LSP Config
    {
        "neovim/nvim-lspconfig",
        enabled = c.lsp,
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("lsp")
        end,
    },

    -- Completion engine
    {
        "hrsh7th/nvim-cmp",
        enabled = c.lsp,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",     -- LSP completion source
            "hrsh7th/cmp-buffer",       -- Buffer completion source
            "hrsh7th/cmp-path",         -- Path completion source
            "hrsh7th/cmp-cmdline",      -- Cmdline completion source
            "L3MON4D3/LuaSnip",         -- Snippet engine
            "saadparwaiz1/cmp_luasnip", -- Snippet completion source
        },
        config = function()
            require("lsp.cmp")
        end,
    },

    -- Copilot (optional)
    {
        "github/copilot.vim",
        enabled = c.copilot,
        event = "InsertEnter",
    },
}
