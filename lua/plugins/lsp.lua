local c = require("config")

return {
    -- Mason (LSP installer)
    {
        "williamboman/mason.nvim",
        enabled = c.lsp,
        cmd = "Mason",
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },

    -- Mason LSP config bridge
    {
        "williamboman/mason-lspconfig.nvim",
        enabled = c.lsp,
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "lua_ls",                -- Lua
                "svelte",                -- Svelte
                "rust_analyzer",         -- Rust
                "eslint",                -- ESLint
                "html",                  -- HTML
                "cssls",                 -- CSS
                "emmet_language_server", -- Emmet
                "jdtls",                 -- Java
                "vtsls",                 -- TypeScript/JavaScript
                "jsonls",                -- JSON
                "yamlls",                -- YAML
                "taplo",                 -- TOML
                "bashls",                -- Bash/sh
                "basedpyright",          -- Python (types)
                "ruff",                  -- Python (lint + format)
            },
            automatic_enable = false, -- servers are enabled in lua/lsp/init.lua
        },
    },

    -- Mason tool installer (formatters, linters, etc.)
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        enabled = c.lsp,
        event = "VeryLazy",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            ensure_installed = {
                "stylua",             -- Lua formatter
                "prettier",           -- JS/TS/JSON/YAML/MD/HTML/CSS/Svelte formatter
                "google-java-format", -- Java formatter
                "shfmt",              -- Shell formatter
                "java-debug-adapter", -- Java DAP (jdtls bundle)
                "java-test",          -- Java test runner (jdtls bundle)
                "codelldb",           -- Rust/C/C++ DAP
            },
            auto_update = false,
            run_on_start = true,
        },
        config = function(_, opts)
            local installer = require("mason-tool-installer")
            installer.setup(opts)
            -- run_on_start hooks VimEnter, which has already fired when loaded lazily
            installer.run_on_start()
        end,
    },

    -- JSON/YAML schemas for jsonls and yamlls (required lazily in lua/lsp/servers.lua)
    { "b0o/SchemaStore.nvim", lazy = true, version = false },

    -- LSP Config
    {
        "neovim/nvim-lspconfig",
        enabled = c.lsp,
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "saghen/blink.cmp",
        },
        config = function()
            -- mason (a dependency, so already set up) has put mason/bin on PATH
            require("lsp")
        end,
    },

    -- Completion engine
    {
        "saghen/blink.cmp",
        enabled = c.lsp,
        version = "1.*", -- release tags ship the prebuilt fuzzy matcher
        event = { "InsertEnter", "CmdlineEnter" },
        opts = {
            keymap = {
                preset = "none",
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
            },
            completion = {
                list = { selection = { preselect = true, auto_insert = false } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                menu = {
                    draw = {
                        columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
                    },
                },
            },
            signature = { enabled = true },
            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = { name = "Dev", module = "lazydev.integrations.blink", score_offset = 100 },
                },
            },
            cmdline = {
                keymap = { preset = "cmdline" },
                completion = { menu = { auto_show = true } },
            },
        },
    },

    -- Copilot (optional)
    {
        "github/copilot.vim",
        enabled = c.copilot,
        event = "InsertEnter",
    },
}
