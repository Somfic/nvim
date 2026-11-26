-- LSP setup orchestrator (using new nvim 0.11 API)
local servers = require("lsp.servers")
local handlers = require("lsp.handlers")

-- Setup handlers first
handlers.setup()

-- Completion capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

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
