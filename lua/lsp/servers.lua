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
                    -- library paths come from lazydev.nvim
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

    -- TypeScript/JavaScript
    vtsls = {
        settings = (function()
            local lang = {
                updateImportsOnFileMove = { enabled = "always" },
                suggest = { completeFunctionCalls = true },
                inlayHints = {
                    parameterNames = { enabled = "all", suppressWhenArgumentMatchesName = true },
                    parameterTypes = { enabled = true },
                    variableTypes = { enabled = true, suppressWhenTypeMatchesName = true },
                    propertyDeclarationTypes = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    enumMemberValues = { enabled = true },
                },
            }
            return {
                complete_function_calls = true,
                vtsls = {
                    autoUseWorkspaceTsdk = true, -- the project's own typescript version
                    enableMoveToFileCodeAction = true,
                    experimental = { completion = { enableServerSideFuzzyMatch = true } },
                },
                typescript = lang,
                javascript = lang,
            }
        end)(),
    },

    -- Svelte
    svelte = {},

    -- ESLint
    eslint = {},

    -- HTML
    html = {},

    -- CSS
    cssls = {},

    -- JSON (schemas from SchemaStore.nvim, loaded when the server starts)
    jsonls = {
        before_init = function(_, config)
            config.settings.json.schemas = require("schemastore").json.schemas()
        end,
        settings = {
            json = { validate = { enable = true } },
        },
    },

    -- YAML (SchemaStore.nvim instead of the server's own schema download)
    yamlls = {
        before_init = function(_, config)
            config.settings.yaml.schemas = require("schemastore").yaml.schemas()
        end,
        settings = {
            yaml = {
                schemaStore = { enable = false, url = "" },
                keyOrdering = false,
            },
        },
    },

    -- TOML (Cargo.toml, pyproject.toml, ...)
    taplo = {},

    -- Bash/sh
    bashls = {},

    -- Python: basedpyright for types, ruff for lint + format
    basedpyright = {
        settings = {
            basedpyright = {
                analysis = { typeCheckingMode = "standard" },
            },
        },
    },
    ruff = {
        on_attach = function(client, bufnr)
            client.server_capabilities.hoverProvider = false -- basedpyright's hover is better
            require("lsp.handlers").on_attach(client, bufnr)
        end,
    },

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
                check = {
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
