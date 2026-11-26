return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>cf",
            function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
            mode = { "n", "v" },
            desc = "Format buffer/selection",
        },
    },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                -- prettier only understands .svelte with prettier-plugin-svelte; without it
                -- in the project, the svelte server formats (it bundles prettier + plugin)
                svelte = function(bufnr)
                    local root = vim.fs.root(bufnr, "package.json")
                    if root and vim.uv.fs_stat(root .. "/node_modules/prettier-plugin-svelte") then
                        return { "prettierd", "prettier", stop_after_first = true }
                    end
                    return { lsp_format = "prefer" }
                end,
                json = { "prettierd", "prettier", stop_after_first = true },
                jsonc = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                rust = { "rustfmt" },
                java = { "google-java-format" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                python = { "ruff_organize_imports", "ruff_format" },
                toml = { "taplo" },
            },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                -- Java is formatted by project build tools; <leader>cf still works manually
                if vim.bo[bufnr].filetype == "java" then
                    return
                end
                return { timeout_ms = 1000, lsp_format = "fallback" }
            end,
        })

        -- Toggle commands
        vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
                vim.b.disable_autoformat = true
            else
                vim.g.disable_autoformat = true
            end
        end, {
            desc = "Disable autoformat-on-save (bang for buffer-only)",
            bang = true,
        })

        vim.api.nvim_create_user_command("FormatEnable", function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
        end, { desc = "Re-enable autoformat-on-save" })
    end,
}
