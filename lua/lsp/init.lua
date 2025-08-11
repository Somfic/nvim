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
local lsp_servers = { 'lua_ls', 'rust_analyzer', 'ts_ls', 'eslint' }
local treesitter_servers = { 'lua', 'rust', 'javascript', 'typescript', 'tsx', 'jsx' }
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
	vim.api.nvim_echo({ { client.name .. ': ' .. result.message, highlight } }, false, {})
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
vim.lsp.config('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
			check = {
				command = 'clippy'
			}
		}
	}
})

vim.lsp.config('ts_ls', {
	filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
	settings = {
		typescript = {
			preferences = {
				quoteStyle = 'single',
				includeCompletionsForImportStatements = true,
				includeCompletionsForModuleExports = true,
			}
		},
		javascript = {
			preferences = {
				quoteStyle = 'single',
				includeCompletionsForImportStatements = true,
				includeCompletionsForModuleExports = true,
			}
		}
	}
})

vim.lsp.config('eslint', {
	filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
	settings = {
		workingDirectories = { mode = 'auto' },
		format = { enable = true },
		codeAction = {
			disableRuleComment = {
				enable = true,
				location = "separateLine"
			},
			showDocumentation = {
				enable = true
			}
		},
		validate = 'on'
	},
	on_attach = function(client, bufnr)
		-- Enable ESLint formatting for JS/TS files
		if client.name == 'eslint' then
			client.server_capabilities.documentFormattingProvider = true
		end
	end
})
require('nvim-treesitter').setup({
	ensure_installed = treesitter_servers,
	highlight = { enable = true }
})
