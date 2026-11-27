-- Right edge of each window: a slim scrollbar (satellite) or a VS Code style
-- minimap (neominimap), both marking diagnostics, git changes and search hits.
-- <leader>um switches between them; the choice is remembered across restarts.
local state_file = vim.fn.stdpath("state") .. "/right_gutter"

local function read_mode()
    local f = io.open(state_file, "r")
    if not f then return "scrollbar" end
    local mode = vim.trim(f:read("*a"))
    f:close()
    return mode == "minimap" and "minimap" or "scrollbar"
end

local mode = read_mode()

local function switch()
    mode = mode == "minimap" and "scrollbar" or "minimap"
    if mode == "minimap" then
        pcall(vim.cmd, "SatelliteDisable")
        vim.cmd("Neominimap Enable")
    else
        vim.cmd("Neominimap Disable")
        pcall(vim.cmd, "SatelliteEnable")
    end
    local f = io.open(state_file, "w")
    if f then
        f:write(mode)
        f:close()
    end
end

return {
    {
        "lewis6991/satellite.nvim",
        event = "VeryLazy",
        config = function()
            require("satellite").setup({
                winblend = 0,
                handlers = {
                    marks = { enable = false },
                    -- deletions as the same bar as additions/changes, told apart by colour
                    gitsigns = { signs = { add = "│", change = "│", delete = "│" } },
                },
            })
            if mode == "minimap" then vim.cmd("SatelliteDisable") end
        end,
    },

    {
        "Isrothy/neominimap.nvim",
        version = "v3.x.x",
        lazy = false, -- does its own lazy loading
        keys = {
            { "<leader>um", switch, desc = "Switch scrollbar / minimap" },
        },
        init = function()
            vim.g.neominimap = {
                auto_enable = mode == "minimap",
                layout = "float",
                float = {
                    minimap_width = 16,
                    window_border = "none",
                },
                exclude_filetypes = {
                    "help", "bigfile", "lazy", "mason", "oil", "neo-tree", "trouble",
                    "snacks_dashboard", "snacks_picker_input", "snacks_picker_list",
                },
                diagnostic = { enabled = true }, -- errors/warnings as coloured lines
                -- git changes as bars, like the sign column (lua/plugins/git.lua)
                git = {
                    enabled = true,
                    mode = "icon",
                    icon = { add = "│ ", change = "│ ", delete = "│ " },
                },
                search = { enabled = true },
            }
        end,
    },
}
