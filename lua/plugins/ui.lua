return {
    -- Themes: all installed so the picker (<leader>uc) can switch between them, and
    -- loaded on demand (lazy loads a theme plugin on :colorscheme). Which
    -- one is applied, and whether it is made transparent, is decided in lua/theme.lua.
    {
        "vague2k/vague.nvim",
        lazy = true, -- loaded by :colorscheme
        config = function()
            require("vague").setup({
                transparent = false, -- transparency is a toggle in lua/theme.lua (<leader>ut)
                style = {
                    boolean = "none",
                    number = "none",
                    float = "none",
                    error = "none",
                    comments = "italic",
                    conditionals = "none",
                    functions = "none",
                    headings = "bold",
                    operators = "none",
                    strings = "none",
                    variables = "none",
                },
            })
        end,
    },

    {
        "tiagovla/tokyodark.nvim",
        lazy = true,
        config = function()
            require("tokyodark").setup({
                transparent_background = false, -- see lua/theme.lua
                gamma = 1.00,
                styles = {
                    comments = { italic = true },
                    keywords = { italic = false },
                    identifiers = { italic = false },
                    functions = {},
                    variables = {},
                },
            })
        end,
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        config = function()
            require("catppuccin").setup({
                flavour = "mocha", -- latte, frappe, macchiato, mocha
                transparent_background = false, -- see lua/theme.lua
                auto_integrations = true, -- theme the plugins lazy has installed
                styles = {
                    comments = { "italic" },
                    conditionals = {},
                },
            })
        end,
    },

    -- More themes, on their defaults (each ships several variants in the picker)
    { "folke/tokyonight.nvim", lazy = true },             -- tokyonight-night/storm/moon/day
    { "rebelot/kanagawa.nvim", lazy = true },             -- kanagawa-wave/dragon/lotus
    { "rose-pine/neovim", name = "rose-pine", lazy = true }, -- rose-pine-main/moon/dawn
    { "EdenEast/nightfox.nvim", lazy = true },            -- nightfox, carbonfox, nordfox, terafox, duskfox, ...
    { "sainnhe/gruvbox-material", lazy = true },
    { "sainnhe/everforest", lazy = true },
    { "navarasu/onedark.nvim", lazy = true },

    -- Icons
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- Which-key (keybinding hints)
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
                preset = "modern",
                delay = 500,
            })
            pcall(wk.add, {
                { "<leader>b", group = "Debug" },
                { "<leader>c", group = "Code" },
                { "<leader>o", desc = "Outline" },
                { "<leader>d", group = "Diagnostics" },
                { "<leader>h", group = "Harpoon" },
                { "<leader>f", group = "Find" },
                { "<leader>g", group = "Goto" },
                { "<leader>gc", group = "Calls" },
                { "<leader>gp", group = "Peek" },
                { "<leader>s", group = "Session" },
                { "<leader>t", group = "Terminal" },
                { "<leader>u", group = "UI" },
                { "<leader>x", group = "Trouble" },
            })

            -- Collapse harpoon slot keybinds into a single display row.
            local harpoon_entries = {
                { "<leader>1", desc = "Harpoon slot 1..9" },
            }
            for i = 2, 9 do
                table.insert(harpoon_entries, { "<leader>" .. i, hidden = true })
            end
            pcall(wk.add, harpoon_entries)
        end,
    },

    -- Bufferline (tabs at top)
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            -- Look up a buffer's harpoon slot index, or nil if not pinned.
            local function harpoon_index_for(bufname)
                local ok, harpoon = pcall(require, "harpoon")
                if not ok or bufname == "" then
                    return nil
                end
                local relpath = vim.fn.fnamemodify(bufname, ":.")
                for i, item in ipairs(harpoon:list().items) do
                    if item.value == relpath or item.value == bufname then
                        return i
                    end
                end
                return nil
            end

            -- Expose globally so harpoon.lua can re-trigger a sort after add/remove.
            _G.bufferline_harpoon_sort = function(a, b)
                local ai = harpoon_index_for(a.path)
                local bi = harpoon_index_for(b.path)
                if ai and bi then
                    return ai < bi
                elseif ai then
                    return true
                elseif bi then
                    return false
                else
                    return a.id < b.id
                end
            end

            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    separator_style = "thick",
                    always_show_bufferline = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    color_icons = true,
                    diagnostics = "nvim_lsp",
                    icon_pinned = "",
                    show_duplicate_prefix = false,
                    sort_by = _G.bufferline_harpoon_sort,
                    numbers = function(opts)
                        local i = harpoon_index_for(vim.api.nvim_buf_get_name(opts.id))
                        return i and (" " .. i) or ""
                    end,
                    offsets = {
                        {
                            filetype = "oil",
                            text = "File Explorer",
                            text_align = "center",
                            separator = true,
                        },
                    },
                },
                highlights = {
                    buffer_selected = {
                        italic = false,
                    },
                    fill = {
                        bg = "none",
                    },
                },
            })
        end,
    },
}
