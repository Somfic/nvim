-- lsp-related packages
vim.pack.add({
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/williamboman/mason.nvim' },
	{ src = 'https://github.com/williamboman/mason-lspconfig.nvim' },
	{ src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
})

-- load lsp modules
require('lsp.progress')
require('lsp.autocomplete')
require('lsp.diagnostics')

-- lsp configuration
local lsp_servers = { 'lua_ls', 'rust_analyzer' }
local treesitter_servers = { 'lua', 'rust' }
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = lsp_servers,
	automatic_installation = true
})

-- enable lsp notifications
vim.lsp.handlers['window/showMessage'] = function(_, result, ctx)
	local client = vim.lsp.get_client_by_id(ctx.client_id)
	local lvl = ({ 'ERROR', 'WARN', 'INFO', 'DEBUG' })[result.type]
	local highlight = ({ 'ErrorMsg', 'WarningMsg', 'Comment', 'Comment' })[result.type]
	vim.api.nvim_echo({{client.name .. ': ' .. result.message, highlight}}, false, {})
end

-- lsp attach notifications
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		_G.lsp_client_attached(client.name)
	end
})

-- lsp detach notifications  
vim.api.nvim_create_autocmd('LspDetach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client then
			_G.lsp_client_detached(client.name)
		end
	end
})

vim.lsp.enable(lsp_servers)
vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true)
			}
		}
	}
})
require('nvim-treesitter').setup({
	ensure_installed = treesitter_servers,
	highlight = { enable = true }
})
