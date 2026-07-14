return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
        local conform = require("conform")

        -- Derive indentation flags from the current buffer's settings, which
        -- guess-indent.nvim detects from the file itself (see indent-detect.lua).
        -- This stops prettier/stylua from hard-coding 2 spaces and clobbering a
        -- tab-indented (or 4-space) file on save. Project .editorconfig /
        -- .prettierrc / stylua.toml still take precedence when present.
        local function buf_indent(bufnr)
            local bo = vim.bo[bufnr]
            local width = bo.shiftwidth
            if width == 0 then width = bo.tabstop end
            return bo.expandtab, width
        end

        local function prettier_indent_args(_, ctx)
            local expandtab, width = buf_indent(ctx.buf)
            local args = { "--tab-width", tostring(width) }
            if not expandtab then
                table.insert(args, "--use-tabs")
            end
            return args
        end

        local function stylua_indent_args(_, ctx)
            local expandtab, width = buf_indent(ctx.buf)
            return {
                "--indent-type", expandtab and "Spaces" or "Tabs",
                "--indent-width", tostring(width),
            }
        end

        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                svelte = { "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", "prettier", stop_after_first = true },
                jsonc = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                rust = { "rustfmt" },
                -- java: formatted by jdtls using the BOS Eclipse profile
                -- (see ftplugin/java.lua); conform's lsp fallback handles it.
                sh = { "shfmt" },
                bash = { "shfmt" },
                nix = { "nixfmt" },
            },

            -- Feed the file's own indentation to each formatter. shfmt already
            -- reads expandtab/shiftwidth (and .editorconfig) on its own, so it
            -- isn't listed here.
            formatters = {
                prettier = { prepend_args = prettier_indent_args },
                prettierd = {
                    -- prettierd wants the filename first, options after.
                    args = function(self, ctx)
                        local a = { "$FILENAME" }
                        vim.list_extend(a, prettier_indent_args(self, ctx))
                        return a
                    end,
                },
                stylua = { prepend_args = stylua_indent_args },
            },

            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                -- 3s ceiling so jdtls's LSP format has room on larger Java files.
                return { timeout_ms = 3000, lsp_fallback = true }
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

        -- Manual format keybind (replaces the LSP-only one in handlers.lua)
        vim.keymap.set({ "n", "v" }, "<leader>rf", function()
            conform.format({ async = true, lsp_fallback = true })
        end, { desc = "Format buffer/selection" })
    end,
}
