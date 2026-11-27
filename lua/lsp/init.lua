-- LSP setup orchestrator (vim.lsp.config / vim.lsp.enable, nvim 0.11+)
local servers = require("lsp.servers")
local handlers = require("lsp.handlers")

handlers.setup()

-- Shared keymaps for every client (including jdtls), via LspAttach rather than
-- on_attach, so servers keep the on_attach nvim-lspconfig ships for them
-- (svelte's TS sync, :LspEslintFixAll, :LspPyrightOrganizeImports, ...)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspSharedKeymaps", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then handlers.on_attach(client, ev.buf) end
  end,
})

-- Completion capabilities from blink.cmp
local capabilities = require("blink.cmp").get_lsp_capabilities()

for server_name, server_config in pairs(servers) do
  vim.lsp.config(server_name, vim.tbl_deep_extend("force", { capabilities = capabilities }, server_config or {}))
end

vim.lsp.enable(vim.tbl_keys(servers))
