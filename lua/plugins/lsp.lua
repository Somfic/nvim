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
                    "rust_analyzer", -- Rust
                    "eslint",        -- ESLint
                },
                automatic_installation = true,
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
