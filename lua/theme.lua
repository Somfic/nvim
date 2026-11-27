-- Colorscheme + transparency, both remembered across restarts.
--
-- The theme is the last one picked (<leader>uc / :colorscheme), else config.theme.
-- Picker previews fire ColorScheme too, but cancelling restores the original, so
-- the saved name always ends on the theme that's actually active.
--
-- Transparency (<leader>ut) works on top of any theme, built-ins included: the
-- themes themselves are configured solid, and this clears the background of the
-- editor's base groups after each theme loads.
--
-- Fires `User ThemeApplied` once a theme and its transparency are in place (the
-- kitty padding follows it).
local state_dir = vim.fn.stdpath("state")
local current -- name of the active colorscheme

local function read(name)
    local f = io.open(state_dir .. "/" .. name, "r")
    if not f then return nil end
    local value = vim.trim(f:read("*a"))
    f:close()
    return value ~= "" and value or nil
end

local function write(name, value)
    local f = io.open(state_dir .. "/" .. name, "w")
    if f then
        f:write(value)
        f:close()
    end
end

vim.g.transparent = read("transparent") ~= "0" -- on unless turned off

local transparent_groups = {
    "Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
    "SignColumn", "FoldColumn", "LineNr", "CursorLineNr", "EndOfBuffer",
    "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "WinBar", "WinBarNC",
    "WinSeparator", "VertSplit", "MsgArea",
    "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
    "TroubleNormal", "TroubleNormalNC",
}

local function clear_backgrounds()
    for _, group in ipairs(transparent_groups) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        if hl.bg or hl.ctermbg then
            hl.bg, hl.ctermbg = nil, nil
            vim.api.nvim_set_hl(0, group, hl)
        end
    end
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ThemeState", { clear = true }),
    callback = function(ev)
        if vim.g.transparent then clear_backgrounds() end
        -- the name as picked (kanagawa-dragon), not g:colors_name (just "kanagawa")
        current = ev.match
        write("colorscheme", ev.match)
        vim.api.nvim_exec_autocmds("User", { pattern = "ThemeApplied" })
    end,
})

local name = read("colorscheme")
if not (name and pcall(vim.cmd.colorscheme, name)) then
    pcall(vim.cmd.colorscheme, require("config").theme)
end

vim.keymap.set("n", "<leader>ut", function()
    vim.g.transparent = not vim.g.transparent
    write("transparent", vim.g.transparent and "1" or "0")
    -- reload the theme so turning it off brings its own backgrounds back
    vim.cmd.colorscheme(current or vim.g.colors_name)
end, { desc = "Toggle transparent background" })
