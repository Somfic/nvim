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

    -- som (`som lsp`)
    som = {
        cmd = function(dispatchers, config)
            local root = (config and config.root_dir) or vim.fs.root(0, { ".git" })
            return vim.lsp.rpc.start({ require("lsp.som").binary(root), "lsp" }, dispatchers, { cwd = root })
        end,
        filetypes = { "som" },
        root_markers = { ".git" },
        on_attach = function(client, bufnr)
            require("lsp.handlers").on_attach(client, bufnr)
            if client:supports_method("textDocument/codeLens") then
                vim.lsp.codelens.refresh({ bufnr = bufnr })
                -- diagnostics arriving means an analysis finished, so lenses are current
                vim.api.nvim_create_autocmd({ "BufEnter", "DiagnosticChanged" }, {
                    buffer = bufnr,
                    callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
                })
                vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { buffer = bufnr, desc = "Run code lens" })
            end
        end,
    },
}
