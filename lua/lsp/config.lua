-- Unified configuration for all languages and frameworks
-- This single source of truth manages LSP servers, icons, filetypes, and treesitter parsers

return {
	lua = {
		lsp_server = 'lua_ls',
		icon = '󰢱',
		color = '#51a0cf',
		filetypes = { 'lua' },
		extensions = { 'lua' },
		treesitter = 'lua',
		settings = {
			Lua = {
				workspace = {
					library = vim.api.nvim_get_runtime_file('', true)
				}
			}
		}
	},

	rust = {
		lsp_server = 'rust_analyzer',
		icon = '󱘗',
		color = '#ce422b',
		filetypes = { 'rust' },
		extensions = { 'rs' },
		treesitter = 'rust',
		special_files = {
			['Cargo.toml'] = ''
		},
		settings = {
			['rust-analyzer'] = {
				check = {
					command = 'clippy',
					features = 'all'
				},
				cargo = {
					allFeatures = true,
					loadOutDirsFromCheck = true,
					runBuildScripts = true,
				},
				procMacro = {
					enable = true
				},
				completion = {
					addCallParenthesis = true,
					addCallArgumentSnippets = true,
					postfix = {
						enable = true
					}
				},
				diagnostics = {
					enable = true,
					enableExperimental = true
				},
				hover = {
					actions = {
						enable = true,
						implementations = { enable = true },
						references = { enable = true },
						run = { enable = true },
						debug = { enable = true }
					}
				},
				inlayHints = {
					bindingModeHints = { enable = false },
					chainingHints = { enable = true },
					closingBraceHints = { enable = true, minLines = 25 },
					closureReturnTypeHints = { enable = "never" },
					lifetimeElisionHints = { enable = "never", useParameterNames = false },
					maxLength = 25,
					parameterHints = { enable = true },
					reborrowHints = { enable = "never" },
					renderColons = true,
					typeHints = {
						enable = true,
						hideClosureInitialization = false,
						hideNamedConstructor = false
					}
				},
				lens = {
					enable = true,
					debug = { enable = true },
					implementations = { enable = true },
					run = { enable = true },
					methodReferences = { enable = true },
					references = {
						adt = { enable = true },
						enumVariant = { enable = true },
						method = { enable = true },
						trait = { enable = true }
					}
				}
			}
		},
		on_attach = function(client, bufnr)
			vim.keymap.set('n', '<leader>rr', function() vim.cmd('!cargo run') end, { desc = 'Cargo run', buffer = bufnr })
			vim.keymap.set('n', '<leader>rt', function() vim.cmd('!cargo test') end, { desc = 'Cargo test', buffer = bufnr })
			vim.keymap.set('n', '<leader>rc', function() vim.cmd('!cargo check') end, { desc = 'Cargo check', buffer = bufnr })
			vim.keymap.set('n', '<leader>rb', function() vim.cmd('!cargo build') end, { desc = 'Cargo build', buffer = bufnr })
			vim.keymap.set('n', '<leader>rd', function() vim.cmd('!cargo doc --open') end, { desc = 'Cargo doc', buffer = bufnr })

			if client.server_capabilities.inlayHintProvider then
				vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			end
		end
	},

	typescript = {
		lsp_server = 'ts_ls',
		icon = '󰛦',
		color = '#3178c6',
		filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
		extensions = { 'ts', 'tsx', 'js', 'jsx' },
		treesitter = { 'typescript', 'tsx', 'javascript', 'jsx' },
		special_files = {
			['package.json'] = '',
			['tsconfig.json'] = '',
			['tsconfig%..*%.json'] = ''
		},
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
			{
				name = "@0no-co/graphqlsp",
				location = "node_modules/@0no-co/graphqlsp/dist/",
			}
		},
		on_attach = function(client, bufnr)
			vim.keymap.set('n', '<leader>gq', function()
				vim.lsp.buf.format({
					filter = function(c) return c.name == 'ts_ls' end
				})
			end, { desc = 'Format GraphQL in TypeScript', buffer = bufnr })
		end
	},

	eslint = {
		lsp_server = 'eslint',
		icon = '󰱺',
		color = '#4b32c3',
		filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
		extensions = {},
		treesitter = nil,
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
			if client.name == 'eslint' then
				client.server_capabilities.documentFormattingProvider = true
			end
		end
	},

	docker = {
		lsp_server = 'dockerls',
		icon = '󰡨',
		color = '#2496ed',
		filetypes = { 'dockerfile' },
		extensions = { 'dockerfile' },
		treesitter = 'dockerfile',
		special_files = {
			['Dockerfile'] = ''
		},
		settings = {
			docker = {
				languageserver = {
					formatter = {
						ignoreMultilineInstructions = true,
					},
				},
			},
		}
	},

	java = {
		lsp_server = 'jdtls',
		icon = '󰬷',
		color = '#f89820',
		filetypes = { 'java' },
		extensions = { 'java' },
		treesitter = 'java',
		settings = {
			java = {
				configuration = {
					runtimes = {
						{ name = "JavaSE-11", path = "/usr/lib/jvm/java-11-openjdk/" },
						{ name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk/" }
					}
				},
				compile = {
					nullAnalysis = { mode = "automatic" }
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
					importOrder = { "java", "javax", "org", "com", "#" }
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
					hashCodeEquals = { useJava7Objects = true },
					useBlocks = true,
				},
				project = {
					referencedLibraries = {
						"lib/**/*.jar",
						"**/target/dependency/*.jar"
					},
				},
				boot = {
					validation = { enabled = true }
				}
			}
		},
		init_options = {
			bundles = {},
		},
		on_attach = function(client, bufnr)
			vim.keymap.set('n', '<leader>sb', function()
				vim.lsp.buf.execute_command({
					command = 'java.project.refreshProjects',
					arguments = { vim.uri_from_fname(vim.fn.expand('%:p:h')) }
				})
			end, { desc = 'Refresh Spring Boot project', buffer = bufnr })

			vim.keymap.set('n', '<leader>sp', function()
				vim.cmd('edit application.properties')
			end, { desc = 'Open application.properties', buffer = bufnr })
		end
	},

	yaml = {
		lsp_server = 'yamlls',
		icon = '󰈙',
		color = '#cb171e',
		filetypes = { 'yaml', 'yml' },
		extensions = { 'yaml', 'yml' },
		treesitter = 'yaml',
		settings = {
			yaml = {
				schemas = {
					["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
					["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
					["https://json.schemastore.org/springboot"] = {
						"application.yml",
						"application-*.yml"
					},
				},
				format = { enable = true },
				validate = true,
				completion = true,
			}
		}
	},

	graphql = {
		lsp_server = 'graphql',
		icon = '󰡷',
		color = '#e535ab',
		filetypes = { 'graphql', 'gql' },
		extensions = { 'graphql', 'gql' },
		treesitter = 'graphql',
		settings = {
			graphql = {
				schema = {
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
					path = {
						"**/*.graphql",
						"**/*.gql",
						"src/**/*.ts",
						"src/**/*.tsx",
						"src/**/*.js",
						"src/**/*.jsx"
					}
				},
				validation = { enabled = true },
				completion = { enabled = true },
				hover = { enabled = true },
				tags = { "gql", "graphql" },
				templateLiterals = { "gql`", "graphql`" }
			}
		},
		root_dir = function(fname)
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
	},

	toml = {
		lsp_server = 'taplo',
		icon = '󰏗',
		color = '#9c4221',
		filetypes = { 'toml' },
		extensions = { 'toml' },
		treesitter = 'toml',
		settings = {
			taplo = {
				schema = {
					associations = {
						["Cargo\\.toml"] = "https://json.schemastore.org/cargo.json",
						["Cargo\\.lock"] = "https://json.schemastore.org/cargo-lock.json"
					}
				}
			}
		}
	},

	json = {
		lsp_server = 'jsonls',
		icon = '󰘦',
		color = '#cbcb41',
		filetypes = { 'json', 'jsonc' },
		extensions = { 'json', 'jsonc' },
		treesitter = 'json',
		settings = {
			json = {
				schemas = {
					{ fileMatch = { "package.json" }, url = "https://json.schemastore.org/package.json" },
					{ fileMatch = { "tsconfig*.json" }, url = "https://json.schemastore.org/tsconfig.json" },
					{ fileMatch = { ".eslintrc", ".eslintrc.json" }, url = "https://json.schemastore.org/eslintrc.json" },
					{ fileMatch = { ".prettierrc", ".prettierrc.json" }, url = "https://json.schemastore.org/prettierrc.json" },
					{ fileMatch = { "docker-compose*.yml", "docker-compose*.yaml" }, url = "https://json.schemastore.org/docker-compose.json" },
					{ fileMatch = { "*.workflow.json", "*.workflow" }, url = "https://json.schemastore.org/github-workflow.json" }
				},
				validate = { enable = true },
				format = { enable = true }
			}
		}
	},

	-- Additional file type icons (no LSP)
	html = {
		icon = '',
		extensions = { 'html' },
		treesitter = nil,
	},

	css = {
		icon = '',
		extensions = { 'css', 'scss' },
		treesitter = nil,
	},

	python = {
		icon = '',
		extensions = { 'py' },
		treesitter = nil,
	},

	xml = {
		icon = '󰗀',
		extensions = { 'xml', 'properties' },
		treesitter = 'xml',
	},

	sql = {
		icon = '',
		extensions = { 'sql' },
		treesitter = nil,
	},

	shell = {
		icon = '',
		extensions = { 'sh', 'bash', 'zsh' },
		treesitter = nil,
	},

	markdown = {
		icon = '',
		extensions = { 'md' },
		treesitter = nil,
	},

	text = {
		icon = '',
		extensions = { 'txt' },
		treesitter = nil,
	},

	env = {
		icon = '',
		special_files = { ['%.env'] = '' },
		treesitter = nil,
	},

	gitignore = {
		icon = '',
		special_files = { ['.gitignore'] = '' },
		treesitter = nil,
	},
}
