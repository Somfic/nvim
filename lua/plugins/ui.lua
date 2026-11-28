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
    { "AlexvZyl/nordic.nvim", lazy = true },
    { "scottmckendry/cyberdream.nvim", lazy = true },
    { "nyoom-engineering/oxocarbon.nvim", lazy = true },
    { "craftzdog/solarized-osaka.nvim", lazy = true },
    { "projekt0n/github-nvim-theme", name = "github-theme", lazy = true }, -- github_dark, github_dark_dimmed, ...
    { "Shatur/neovim-ayu", lazy = true },                 -- ayu-dark/mirage/light
    { "ribru17/bamboo.nvim", lazy = true },
    { "savq/melange-nvim", lazy = true },
    { "Mofiqul/dracula.nvim", lazy = true },
    { "dgox16/oldworld.nvim", lazy = true },
    { "olivercederborg/poimandres.nvim", lazy = true },
    { "Mofiqul/vscode.nvim", lazy = true },

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

            local function color(group, attr)
                local v = vim.api.nvim_get_hl(0, { name = group, link = false })[attr]
                return v and ("#%06x"):format(v) or nil
            end

            -- Color of the current mode: lualine's mode block when it's loaded,
            -- else a theme color per mode.
            local fallback = {
                i = "String", v = "Statement", V = "Statement", ["\22"] = "Statement",
                s = "Statement", S = "Statement", R = "Error", c = "Constant", t = "String",
            }
            local function mode_color()
                local ok, lualine_hl = pcall(require, "lualine.highlight")
                local bg = ok and (color("lualine_a" .. lualine_hl.get_mode_suffix(), "bg")
                    or color("lualine_a_normal", "bg"))
                return bg or color(fallback[vim.fn.mode():sub(1, 1)] or "Function", "fg")
            end

            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    -- No separator blocks: tabs are plain text on the editor's
                    -- background, the current one marked by a bar in the mode's color.
                    separator_style = { "", "" },
                    indicator = { icon = "▎", style = "icon" },
                    modified_icon = "", -- buffers are auto-saved
                    tab_size = 14,
                    diagnostics_indicator = function(_, level)
                        local icons = { error = " ", warning = " " }
                        return icons[level] or ""
                    end,
                    always_show_bufferline = true,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    color_icons = true,
                    diagnostics = "nvim_lsp",
                    icon_pinned = "",
                    show_duplicate_prefix = false,
                    sort_by = _G.bufferline_harpoon_sort,
                    -- Harpoon slot goes in the name, not `numbers`: bufferline pads
                    -- after the number even when it's empty, pushing unpinned tabs right.
                    name_formatter = function(buf)
                        local i = harpoon_index_for(buf.path)
                        return i and (i .. " " .. buf.name) or buf.name
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
                -- Re-run on every :colorscheme (so it follows the theme and the
                -- transparency toggle, which lua/theme.lua applies first) and on
                -- every mode change (see below).
                highlights = function(defaults)
                    local base = color("Normal", "bg") or "NONE"
                    local selected = color("CursorLine", "bg") or base
                    local dim = color("Comment", "fg")
                    local bright = color("Normal", "fg")

                    local hl = {}
                    for name in pairs(defaults.highlights) do
                        hl[name] = { bg = name:match("_selected$") and selected or base }
                    end
                    hl.fill = { bg = base }
                    hl.background = { fg = dim, bg = base }
                    hl.buffer_visible = { fg = dim, bg = base }
                    hl.buffer_selected = { fg = bright, bg = selected, bold = true, italic = false }
                    hl.indicator_selected = { fg = mode_color(), bg = selected }
                    hl.indicator_visible = { fg = base, bg = base }
                    hl.separator = { fg = base, bg = base }
                    hl.separator_visible = { fg = base, bg = base }
                    hl.separator_selected = { fg = base, bg = selected }
                    hl.offset_separator = { fg = dim, bg = base }
                    return hl
                end,
            })

            -- Recolor the current tab's bar on mode change. Set directly: bufferline
            -- sets its groups as `default`, which won't overwrite an existing one.
            vim.api.nvim_create_autocmd("ModeChanged", {
                group = vim.api.nvim_create_augroup("BufferlineModeColor", { clear = true }),
                callback = function()
                    local hl = vim.api.nvim_get_hl(0, { name = "BufferLineIndicatorSelected" })
                    local fg = mode_color()
                    if not fg or hl.fg == tonumber(fg:sub(2), 16) then return end
                    hl.fg = fg
                    hl.default = nil
                    vim.api.nvim_set_hl(0, "BufferLineIndicatorSelected", hl)
                end,
            })
        end,
    },
}
