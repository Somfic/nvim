-- completion-related packages
vim.pack.add({
	{ src = 'https://github.com/hrsh7th/nvim-cmp' },
	{ src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
	{ src = 'https://github.com/hrsh7th/cmp-buffer' },
	{ src = 'https://github.com/hrsh7th/cmp-path' },
	{ src = 'https://github.com/hrsh7th/cmp-cmdline' },
	{ src = 'https://github.com/L3MON4D3/LuaSnip' },
	{ src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
	{ src = 'https://github.com/zbirenbaum/copilot-cmp' },
})

local cmp = require('cmp')
local luasnip = require('luasnip')

-- Setup copilot-cmp integration
require('copilot_cmp').setup()

-- completion menu icons
local kind_icons = {
	Text = "󰊄",
	Method = "󰊕",
	Function = "󰊕",
	Constructor = "󰒓",
	Field = "󰜢",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "󰜰",
	Module = "󰏗",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "󰕘",
	Keyword = "󰌋",
	Snippet = "󰩫",
	Color = "󰏘",
	File = "󰈔",
	Reference = "󰈇",
	Folder = "󰉋",
	EnumMember = "󰕘",
	Constant = "󰏿",
	Struct = "󰙅",
	Event = "󱐋",
	Operator = "󰆕",
	TypeParameter = "󰊄",
	Copilot = "󰚩",
}

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	window = {
		completion = {
			border = 'rounded',
			winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None',
		},
		documentation = {
			border = 'rounded',
			winhighlight = 'Normal:CmpDoc,FloatBorder:CmpBorder',
		},
	},
	completion = {
		completeopt = 'menu,menuone,noinsert,noselect',
		keyword_length = 1,
	},
	formatting = {
		format = function(entry, vim_item)
			-- add kind icons
			vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
			
			-- set a name for each source
			vim_item.menu = ({
				copilot = '[Copilot]',
				nvim_lsp = '[LSP]',
				luasnip = '[Snippet]',
				buffer = '[Buffer]',
				path = '[Path]',
			})[entry.source.name]
			
			-- truncate long completion items
			if string.len(vim_item.abbr) > 50 then
				vim_item.abbr = string.sub(vim_item.abbr, 1, 47) .. '...'
			end
			
			return vim_item
		end
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ 
			behavior = cmp.ConfirmBehavior.Replace,
			select = false 
		}),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),
	}),
	sources = cmp.config.sources({
		{ name = 'copilot', priority = 1100 },
		{ 
			name = 'nvim_lsp', 
			priority = 1000,
			trigger_characters = { '.', ':', '(', '"', "'", '/', '@', '*' }
		},
		{ name = 'luasnip', priority = 750 },
		{ name = 'buffer', priority = 500, keyword_length = 3 },
		{ name = 'path', priority = 250 },
	}),
	performance = {
		debounce = 60,
		throttle = 30,
		fetching_timeout = 500,
		confirm_resolve_timeout = 80,
		async_budget = 1,
		max_view_entries = 200,
	},
	experimental = {
		ghost_text = {
			hl_group = 'Comment',
		},
	},
})

-- setup cmdline completion
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

-- completion menu colors
vim.api.nvim_set_hl(0, 'CmpPmenu', { bg = '#2d2d2d', fg = '#ffffff' })
vim.api.nvim_set_hl(0, 'CmpBorder', { bg = '#2d2d2d', fg = '#6a6a6a' })
vim.api.nvim_set_hl(0, 'CmpDoc', { bg = '#1e1e1e', fg = '#ffffff' })

-- setup lsp capabilities for completion
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- export capabilities for use in lsp configs
_G.cmp_capabilities = capabilities