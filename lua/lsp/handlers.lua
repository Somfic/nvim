local M = {}

-- Setup LSP handlers
function M.setup()
    -- Configure diagnostics
    vim.diagnostic.config({
        virtual_text = true,
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN]  = "",
                [vim.diagnostic.severity.INFO]  = "",
                [vim.diagnostic.severity.HINT]  = "",
            },
        },
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    })

    -- Default hover/signature_help to a rounded border (vim.lsp.with was removed in 0.11)
    local orig_hover = vim.lsp.buf.hover
    vim.lsp.buf.hover = function(cfg)
        return orig_hover(vim.tbl_extend("force", { border = "rounded" }, cfg or {}))
    end
    local orig_sig = vim.lsp.buf.signature_help
    vim.lsp.buf.signature_help = function(cfg)
        return orig_sig(vim.tbl_extend("force", { border = "rounded" }, cfg or {}))
    end

    -- Truncate long inlay hint labels so they don't push the actual value off-screen
    local max_inlay_len = 40
    local function truncate(s)
        if #s > max_inlay_len then
            return s:sub(1, max_inlay_len - 1) .. "…"
        end
        return s
    end
    local orig_inlay_handler = vim.lsp.handlers["textDocument/inlayHint"]
    vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
        if result then
            for _, hint in ipairs(result) do
                if type(hint.label) == "string" then
                    hint.label = truncate(hint.label)
                elseif type(hint.label) == "table" then
                    -- Truncate the joined label, replace with a single part
                    local joined = ""
                    for _, part in ipairs(hint.label) do
                        joined = joined .. (part.value or "")
                    end
                    if #joined > max_inlay_len then
                        hint.label = { { value = truncate(joined) } }
                    end
                end
            end
        end
        return orig_inlay_handler(err, result, ctx, config)
    end

    -- Italic inlay hints (preserve existing fg/bg from colorscheme)
    local function italicize_inlay_hints()
        local existing = vim.api.nvim_get_hl(0, { name = "LspInlayHint", link = false })
        existing.italic = true
        existing.cterm = vim.tbl_extend("force", existing.cterm or {}, { italic = true })
        vim.api.nvim_set_hl(0, "LspInlayHint", existing)
    end
    italicize_inlay_hints()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = italicize_inlay_hints,
    })

    -- Bind LSP keymaps via LspAttach so every attaching client gets them,
    -- regardless of how the server was started (lspconfig, jdtls.start_or_attach, etc.).
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach_keymaps", { clear = true }),
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if not client then return end

            vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

            local opts = { buffer = bufnr, silent = true }
            local function map_if(method, mode, lhs, rhs, desc)
                if client:supports_method(method) then
                    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
                end
            end

            -- Goto (Trouble panel)
            map_if("textDocument/definition",     "n", "<leader>gd",  "<cmd>Trouble lsp_definitions toggle focus=true<cr>",       "Definitions")
            map_if("textDocument/references",     "n", "<leader>gu",  "<cmd>Trouble lsp_references toggle focus=true<cr>",        "Usages")
            map_if("textDocument/implementation", "n", "<leader>gi",  "<cmd>Trouble lsp_implementations toggle focus=true<cr>",   "Implementations")
            map_if("textDocument/typeDefinition", "n", "<leader>gt",  "<cmd>Trouble lsp_type_definitions toggle focus=true<cr>",  "Type definitions")
            map_if("textDocument/documentSymbol", "n", "<leader>gs",  "<cmd>Trouble lsp_document_symbols toggle focus=true<cr>",  "Document symbols")
            map_if("textDocument/prepareCallHierarchy", "n", "<leader>gci", "<cmd>Trouble lsp_incoming_calls toggle focus=true<cr>", "Incoming calls")
            map_if("textDocument/prepareCallHierarchy", "n", "<leader>gco", "<cmd>Trouble lsp_outgoing_calls toggle focus=true<cr>", "Outgoing calls")

            -- Hover and help
            map_if("textDocument/hover",         "n", "K",     vim.lsp.buf.hover,          "Hover documentation")
            map_if("textDocument/signatureHelp", "n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")

            -- Refactor
            map_if("textDocument/codeAction", "n", "<leader>ra", vim.lsp.buf.code_action, "Code action")
            map_if("textDocument/codeAction", "n", "<leader>.",  vim.lsp.buf.code_action, "Code action")
            map_if("textDocument/rename",     "n", "<leader>rr", vim.lsp.buf.rename,      "Rename symbol")

            -- Diagnostics
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
            vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float,
                vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))
            vim.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist,
                vim.tbl_extend("force", opts, { desc = "Diagnostic loclist" }))

            -- Inlay hints
            if client:supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                vim.keymap.set("n", "<leader>uh", function()
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
                end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))
            end

            -- Highlight symbol under cursor
            if client.server_capabilities.documentHighlightProvider then
                vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
                vim.api.nvim_clear_autocmds({ buffer = bufnr, group = "lsp_document_highlight" })
                vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                    group = "lsp_document_highlight",
                    buffer = bufnr,
                    callback = vim.lsp.buf.document_highlight,
                })
                vim.api.nvim_create_autocmd("CursorMoved", {
                    group = "lsp_document_highlight",
                    buffer = bufnr,
                    callback = vim.lsp.buf.clear_references,
                })
            end
        end,
    })
end

-- Kept as a no-op for backwards compatibility with servers.lua / ftplugin/java.lua
-- (keymaps are now bound via LspAttach inside M.setup())
function M.on_attach(_, _) end

return M
