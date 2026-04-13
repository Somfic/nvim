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

    -- LSP handlers with borders
    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
    })

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
end

-- On attach function (runs when LSP attaches to buffer)
function M.on_attach(client, bufnr)
    -- Enable completion
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Keybindings
    local opts = { buffer = bufnr, silent = true }

    -- Bind a keymap only if the attached LSP supports the given method
    local tb = require("telescope.builtin")
    local function map_if(method, mode, lhs, rhs, desc)
        if client:supports_method(method) then
            vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
        end
    end

    -- Goto (Trouble panel — grouped by file with inline preview)
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
end

return M
