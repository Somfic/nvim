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
require('lsp.completions')
require('lsp.copilot')

-- load unified language configuration
local lang_config = require('lsp.config')

-- extract lsp servers and treesitter parsers from config
local lsp_servers = {}
local treesitter_parsers = {}

for lang, config in pairs(lang_config) do
	if config.lsp_server then
		table.insert(lsp_servers, config.lsp_server)
	end

	if config.treesitter then
		if type(config.treesitter) == 'table' then
			for _, parser in ipairs(config.treesitter) do
				table.insert(treesitter_parsers, parser)
			end
		else
			table.insert(treesitter_parsers, config.treesitter)
		end
	end
end

-- setup mason and mason-lspconfig
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = lsp_servers,
	automatic_installation = true
})

-- auto-install missing servers on startup
vim.defer_fn(function()
	local mason_registry = require('mason-registry')

	for _, server in ipairs(lsp_servers) do
		if not mason_registry.is_installed(server) then
			pcall(function()
				mason_registry.get_package(server):install()
			end)
		end
	end
end, 100)

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
		if client then
			vim.defer_fn(function()
				_G.lsp_client_attached(client.name)
			end, 500)
		end
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

-- enable lsp servers
vim.lsp.enable(lsp_servers)

-- configure each lsp server from unified config
for lang, config in pairs(lang_config) do
	if config.lsp_server then
		local lsp_config = {
			capabilities = _G.cmp_capabilities,
		}

		-- add filetypes if specified
		if config.filetypes then
			lsp_config.filetypes = config.filetypes
		end

		-- add settings if specified
		if config.settings then
			lsp_config.settings = config.settings
		end

		-- add plugins if specified
		if config.plugins then
			lsp_config.plugins = config.plugins
		end

		-- add root_dir if specified
		if config.root_dir then
			lsp_config.root_dir = config.root_dir
		end

		-- add init_options if specified
		if config.init_options then
			lsp_config.init_options = config.init_options
		end

		-- add on_attach if specified
		if config.on_attach then
			lsp_config.on_attach = config.on_attach
		end

		vim.lsp.config(config.lsp_server, lsp_config)
	end
end

-- setup treesitter with all parsers from config
require('nvim-treesitter').setup({
	ensure_installed = treesitter_parsers,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = { 'graphql' }
	},
	injections = {
		enable = true,
		graphql = {
			typescript = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))",
			javascript = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))",
			typescriptreact = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))",
			javascriptreact = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))"
		}
	}
})
