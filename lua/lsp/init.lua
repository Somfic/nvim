-- LSP setup orchestrator (using new nvim 0.11 API)
local servers = require("lsp.servers")
local handlers = require("lsp.handlers")

-- Setup handlers first
handlers.setup()

-- Get capabilities from cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Setup each server using new vim.lsp.config API
for server_name, server_config in pairs(servers) do
    local opts = {
        capabilities = capabilities,
        on_attach = handlers.on_attach,
    }

    -- Merge server-specific config
    if server_config then
        opts = vim.tbl_deep_extend("force", opts, server_config)
    end

    -- Use new vim.lsp.config API
    vim.lsp.config(server_name, opts)
end

-- Enable servers
vim.lsp.enable(vim.tbl_keys(servers))
