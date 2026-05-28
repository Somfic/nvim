-- LSP server configurations
return {
    -- Lua
    lua_ls = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = { enable = false },
                hint = {
                    enable = true,
                    arrayIndex = "Disable",
                    setType = true,
                    paramName = "All",
                    paramType = true,
                },
            },
        },
    },

    -- TypeScript/JavaScript handled by typescript-tools.nvim (see lua/plugins/typescript-tools.lua)

    -- Svelte
    svelte = {},

    -- ESLint
    eslint = {},

    -- HTML
    html = {},

    -- CSS
    cssls = {},

    -- Emmet (HTML/CSS/JSX/TSX/Svelte/Vue abbreviation expansion)
    emmet_language_server = {
        filetypes = {
            "html", "css", "scss", "sass", "less",
            "javascriptreact", "typescriptreact",
            "svelte", "vue", "htmldjango",
        },
    },

    -- C/C++
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
        },
    },

    -- Rust
    rust_analyzer = {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
                inlayHints = {
                    bindingModeHints = { enable = true },
                    closureReturnTypeHints = { enable = "always" },
                    lifetimeElisionHints = { enable = "skip_trivial" },
                    typeHints = { enable = true },
                    parameterHints = { enable = true },
                },
            },
        },
    },
}
