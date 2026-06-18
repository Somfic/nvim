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

    -- Nix (nixd, installed via nix — see modules/home/development/core.nix)
    nixd = {},

    -- just (just-lsp, installed via nix — see modules/home/development/core.nix)
    just = {},

    -- Svelte
    svelte = {},

    -- ESLint
    eslint = {},

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

    -- C# / .NET
    omnisharp = {
        cmd = { "omnisharp" },
        settings = {
            FormattingOptions = {
                EnableEditorConfigSupport = true,
                OrganizeImports = true,
            },
            RoslynExtensionsOptions = {
                EnableAnalyzersSupport = true,
                EnableImportCompletion = true,
                AnalyzeOpenDocumentsOnly = true,
            },
            Sdk = {
                IncludePrereleases = true,
            },
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
