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
            source = true,
            header = "",
            prefix = "",
        },
    })

    -- Truncate long inlay hint labels so they don't push the actual value off-screen
    local max_inlay_len = 40
    local function truncate(s)
        if #s > max_inlay_len then
            return s:sub(1, max_inlay_len - 1) .. "…"
        end
        return s
    end
    -- Name of the function whose argument list contains `col` (0-based), from the
    -- unmatched "(" before it; nil when the call starts on an earlier line
    local function callee(line, col)
        local depth = 0
        for i = math.min(col, #line), 1, -1 do
            local c = line:sub(i, i)
            if c == ")" then
                depth = depth + 1
            elseif c == "(" then
                if depth == 0 then return line:sub(1, i - 1):match("([%w_]+)%s*$") end
                depth = depth - 1
            end
        end
    end

    -- Parameter hints the call already spells out, like IntelliJ:
    -- setSystemExternalEta(systemExternalEta: ...), withName(name: ...)
    local function redundant(hint, bufnr)
        if hint.kind ~= 2 then return false end -- 2 = Parameter
        local label = type(hint.label) == "string" and hint.label
            or table.concat(vim.tbl_map(function(p) return p.value or "" end, hint.label))
        local param = vim.trim(label):gsub("[:=]$", "")
        if param == "" then return false end
        local line = vim.api.nvim_buf_get_lines(bufnr, hint.position.line, hint.position.line + 1, false)[1]
        local name = line and callee(line, hint.position.character)
        if not name then return false end
        -- ends with the parameter name at a camelCase boundary (or is it)
        local capitalized = param:sub(1, 1):upper() .. param:sub(2)
        return name == param or name:sub(-#capitalized) == capitalized
    end

    local orig_inlay_handler = vim.lsp.handlers["textDocument/inlayHint"]
    vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
        if result then
            result = vim.tbl_filter(function(hint) return not redundant(hint, ctx.bufnr) end, result)
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

    -- Inlay hints (and the schedule hints, which reuse this group) in the same
    -- italic comment colour as the usages above methods, no background
    local function style_inlay_hints()
        local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = comment.fg, ctermfg = comment.ctermfg, italic = true })
    end
    style_inlay_hints()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = style_inlay_hints,
    })
end

-- On attach function (runs when LSP attaches to buffer)
function M.on_attach(client, bufnr)
    -- Enable completion
    vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Keybindings
    local opts = { buffer = bufnr, silent = true }

    -- Bind a keymap only if the attached LSP supports the given method
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
    -- signature help: blink shows it while typing; <C-s> in insert mode opens it
    map_if("textDocument/hover",         "n", "K",     vim.lsp.buf.hover,          "Hover documentation")

    -- Refactor
    map_if("textDocument/codeAction", { "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    map_if("textDocument/rename",     "n",          "<leader>cr", vim.lsp.buf.rename,      "Rename symbol")

    -- Diagnostics
    vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
        vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
    vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
        vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
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
