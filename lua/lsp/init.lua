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

-- lsp configuration
local lsp_servers = { 'lua_ls', 'rust_analyzer', 'ts_ls', 'eslint', 'dockerls', 'jdtls', 'yamlls', 'graphql', 'taplo', 'jsonls' }
local treesitter_servers = { 'lua', 'rust', 'javascript', 'typescript', 'tsx', 'jsx', 'dockerfile', 'java', 'yaml', 'xml', 'properties', 'graphql', 'toml', 'json' }
require('mason').setup()
require('mason-lspconfig').setup({
	ensure_installed = lsp_servers,
	automatic_installation = true
})

-- Auto-install missing servers on startup
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
			-- delay slightly to ensure LSP is fully ready
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



vim.lsp.enable(lsp_servers)
vim.lsp.config('lua_ls', {
	capabilities = _G.cmp_capabilities,
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file('', true)
			}
		}
	}
})
vim.lsp.config('rust_analyzer', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'rust' },
	settings = {
		['rust-analyzer'] = {
			-- Use clippy for additional lints
			check = {
				command = 'clippy',
				features = 'all'
			},
			-- Cargo settings
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
				runBuildScripts = true,
			},
			-- Proc macro support
			procMacro = {
				enable = true
			},
			-- Completion settings
			completion = {
				addCallParenthesis = true,
				addCallArgumentSnippets = true,
				postfix = {
					enable = true
				}
			},
			-- Diagnostics
			diagnostics = {
				enable = true,
				enableExperimental = true
			},
			-- Hover and inlay hints
			hover = {
				actions = {
					enable = true,
					implementations = {
						enable = true
					},
					references = {
						enable = true
					},
					run = {
						enable = true
					},
					debug = {
						enable = true
					}
				}
			},
			inlayHints = {
				bindingModeHints = {
					enable = false
				},
				chainingHints = {
					enable = true
				},
				closingBraceHints = {
					enable = true,
					minLines = 25
				},
				closureReturnTypeHints = {
					enable = "never"
				},
				lifetimeElisionHints = {
					enable = "never",
					useParameterNames = false
				},
				maxLength = 25,
				parameterHints = {
					enable = true
				},
				reborrowHints = {
					enable = "never"
				},
				renderColons = true,
				typeHints = {
					enable = true,
					hideClosureInitialization = false,
					hideNamedConstructor = false
				}
			},
			-- Code lens
			lens = {
				enable = true,
				debug = {
					enable = true
				},
				implementations = {
					enable = true
				},
				run = {
					enable = true
				},
				methodReferences = {
					enable = true
				},
				references = {
					adt = {
						enable = true
					},
					enumVariant = {
						enable = true
					},
					method = {
						enable = true
					},
					trait = {
						enable = true
					}
				}
			}
		}
	},
	on_attach = function(client, bufnr)
		-- Rust-specific keymaps
		vim.keymap.set('n', '<leader>rr', function()
			vim.cmd('!cargo run')
		end, { desc = 'Cargo run', buffer = bufnr })
		
		vim.keymap.set('n', '<leader>rt', function()
			vim.cmd('!cargo test')
		end, { desc = 'Cargo test', buffer = bufnr })
		
		vim.keymap.set('n', '<leader>rc', function()
			vim.cmd('!cargo check')
		end, { desc = 'Cargo check', buffer = bufnr })
		
		vim.keymap.set('n', '<leader>rb', function()
			vim.cmd('!cargo build')
		end, { desc = 'Cargo build', buffer = bufnr })
		
		vim.keymap.set('n', '<leader>rd', function()
			vim.cmd('!cargo doc --open')
		end, { desc = 'Cargo doc', buffer = bufnr })
		
		-- Enable inlay hints
		if client.server_capabilities.inlayHintProvider then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		end
	end
})

vim.lsp.config('ts_ls', {
	capabilities = _G.cmp_capabilities,
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
	},
	plugins = {
		-- Add TypeScript GraphQL plugin for template literal support
		{
			name = "@0no-co/graphqlsp",
			location = "node_modules/@0no-co/graphqlsp/dist/",
		}
	},
	on_attach = function(client, bufnr)
		-- GraphQL specific keymaps for TSX files
		vim.keymap.set('n', '<leader>gq', function()
			-- Format GraphQL queries in template literals
			vim.lsp.buf.format({ 
				filter = function(c) return c.name == 'ts_ls' end 
			})
		end, { desc = 'Format GraphQL in TypeScript', buffer = bufnr })
	end
})

vim.lsp.config('eslint', {
	capabilities = _G.cmp_capabilities,
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

vim.lsp.config('dockerls', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'dockerfile' },
	settings = {
		docker = {
			languageserver = {
				formatter = {
					ignoreMultilineInstructions = true,
				},
			},
		},
	}
})

vim.lsp.config('jdtls', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'java' },
	settings = {
		java = {
			configuration = {
				runtimes = {
					{
						name = "JavaSE-11",
						path = "/usr/lib/jvm/java-11-openjdk/",
					},
					{
						name = "JavaSE-17",
						path = "/usr/lib/jvm/java-17-openjdk/",
					}
				}
			},
			compile = {
				nullAnalysis = {
					mode = "automatic"
				}
			},
			completion = {
				favoriteStaticMembers = {
					"org.hamcrest.MatcherAssert.assertThat",
					"org.hamcrest.Matchers.*",
					"org.hamcrest.CoreMatchers.*",
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.springframework.boot.test.context.SpringBootTest.*",
					"org.springframework.test.web.servlet.MockMvcRequestBuilders.*",
					"org.springframework.test.web.servlet.result.MockMvcResultMatchers.*"
				},
				importOrder = {
					"java",
					"javax",
					"org",
					"com",
					"#"
				}
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				}
			},
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
				},
				hashCodeEquals = {
					useJava7Objects = true,
				},
				useBlocks = true,
			},
			-- Spring Boot specific settings
			project = {
				referencedLibraries = {
					"lib/**/*.jar",
					"**/target/dependency/*.jar"
				},
			},
			-- Enable Spring Boot tools
			boot = {
				validation = {
					enabled = true
				}
			}
		}
	},
	init_options = {
		bundles = {},
	},
	on_attach = function(client, bufnr)
		-- Spring Boot specific keymaps
		vim.keymap.set('n', '<leader>sb', function()
			vim.lsp.buf.execute_command({
				command = 'java.project.refreshProjects',
				arguments = { vim.uri_from_fname(vim.fn.expand('%:p:h')) }
			})
		end, { desc = 'Refresh Spring Boot project', buffer = bufnr })
		
		-- Create application.properties file completion
		vim.keymap.set('n', '<leader>sp', function()
			vim.cmd('edit application.properties')
		end, { desc = 'Open application.properties', buffer = bufnr })
	end
})

vim.lsp.config('yamlls', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'yaml', 'yml' },
	settings = {
		yaml = {
			schemas = {
				-- Spring Boot application.yml schema
				["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
				["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
				-- Spring Boot configuration schema
				["https://json.schemastore.org/springboot"] = {
					"application.yml",
					"application-*.yml"
				},
			},
			format = {
				enable = true,
			},
			validate = true,
			completion = true,
		}
	}
})

vim.lsp.config('graphql', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'graphql', 'gql' },
	settings = {
		graphql = {
			schema = {
				-- Common GraphQL schema file patterns
				path = {
					"schema.graphql",
					"schema.json",
					"**/*.graphql",
					"**/*.gql",
					"src/schema/**/*.graphql",
					"src/graphql/**/*.graphql",
					"graphql/schema.graphql"
				}
			},
			documents = {
				-- GraphQL query/mutation files including template literals
				path = {
					"**/*.graphql",
					"**/*.gql", 
					"src/**/*.ts",
					"src/**/*.tsx",
					"src/**/*.js",
					"src/**/*.jsx"
				}
			},
			validation = {
				enabled = true
			},
			completion = {
				enabled = true
			},
			hover = {
				enabled = true
			},
			-- Enable GraphQL in template literals
			tags = {
				"gql",
				"graphql"
			},
			-- Template literal patterns
			templateLiterals = {
				"gql`",
				"graphql`"
			}
		}
	},
	root_dir = function(fname)
		-- Look for GraphQL config files
		local util = require('lspconfig.util')
		return util.root_pattern(
			'.graphqlrc',
			'.graphqlrc.json',
			'.graphqlrc.yaml',
			'.graphqlrc.yml',
			'graphql.config.js',
			'graphql.config.ts',
			'codegen.yml',
			'codegen.yaml',
			'codegen.json',
			'package.json'
		)(fname) or util.find_git_ancestor(fname)
	end
})

vim.lsp.config('taplo', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'toml' },
	settings = {
		taplo = {
			schema = {
				-- Cargo.toml schema for better completion
				associations = {
					["Cargo\\.toml"] = "https://json.schemastore.org/cargo.json",
					["Cargo\\.lock"] = "https://json.schemastore.org/cargo-lock.json"
				}
			}
		}
	}
})

vim.lsp.config('jsonls', {
	capabilities = _G.cmp_capabilities,
	filetypes = { 'json', 'jsonc' },
	settings = {
		json = {
			schemas = {
				{
					fileMatch = { "package.json" },
					url = "https://json.schemastore.org/package.json"
				},
				{
					fileMatch = { "tsconfig*.json" },
					url = "https://json.schemastore.org/tsconfig.json"
				},
				{
					fileMatch = { ".eslintrc", ".eslintrc.json" },
					url = "https://json.schemastore.org/eslintrc.json"
				},
				{
					fileMatch = { ".prettierrc", ".prettierrc.json" },
					url = "https://json.schemastore.org/prettierrc.json"
				},
				{
					fileMatch = { "docker-compose*.yml", "docker-compose*.yaml" },
					url = "https://json.schemastore.org/docker-compose.json"
				},
				{
					fileMatch = { "*.workflow.json", "*.workflow" },
					url = "https://json.schemastore.org/github-workflow.json"
				}
			},
			validate = { enable = true },
			format = { enable = true }
		}
	}
})

require('nvim-treesitter').setup({
	ensure_installed = treesitter_servers,
	auto_install = true,  -- Auto-install missing parsers
	highlight = { 
		enable = true,
		-- Enable additional syntax highlighting for GraphQL in template literals
		additional_vim_regex_highlighting = { 'graphql' }
	},
	-- Enable GraphQL injections in TypeScript/JavaScript
	injections = {
		enable = true,
		-- GraphQL template literal injection
		graphql = {
			typescript = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))",
			javascript = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))",
			typescriptreact = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))",
			javascriptreact = "((call_expression (identifier) @_name (#eq? @_name \"gql\")) (template_string (string_fragment) @graphql))"
		}
	}
})
