-- Make kitty match the colorscheme. A transparent theme (Normal has no bg) keeps
-- kitty as configured: padding, glass. A solid theme makes kitty flush with it: no
-- padding, the theme's background as kitty's own (it fills the leftover pixels
-- around the cell grid), and full opacity (kitty's opacity only covers its own
-- background, so a see-through edge would remain). Re-applied whenever
-- lua/theme.lua changes the theme or its transparency; all reset on exit/suspend.
--
-- The background is set with OSC 11 (this window only, no permission needed).
-- Padding and opacity go over kitty's socket: `kitty @` over the tty doesn't work
-- from inside nvim, which owns the tty. Needs remote control + listen_on (see
-- modules/home/development/editors.nix).
local socket = vim.env.KITTY_LISTEN_ON
if not vim.env.KITTY_WINDOW_ID or not socket or vim.fn.executable("kitty") == 0 then
    return
end

-- run `kitty @ <command> [flags] <value>` against this window
local function kitty(command, value, flags)
    local cmd = { "kitty", "@", "--to", socket, "--password=nvim", command }
    vim.list_extend(cmd, flags or {})
    vim.list_extend(cmd, { "--match", "id:" .. vim.env.KITTY_WINDOW_ID, value })
    return vim.system(cmd, { text = true }, function(res)
        if res.code ~= 0 then
            vim.schedule(function()
                vim.notify("kitty: " .. vim.trim(res.stderr or ""), vim.log.levels.WARN)
            end)
        end
    end)
end

local function solid(bg)
    vim.api.nvim_ui_send(("\27]11;#%06x\27\\"):format(bg))
    return {
        kitty("set-spacing", "padding=0"),
        kitty("set-background-opacity", "1"),
    }
end

local function configured()
    vim.api.nvim_ui_send("\27]111\27\\") -- back to kitty's own background
    return {
        kitty("set-spacing", "padding=default"),
        -- --toggle resets to the configured opacity when it's currently 1
        kitty("set-background-opacity", "1", { "--toggle" }),
    }
end

local is_solid = false

local function apply()
    local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
    if bg then
        solid(bg)
        is_solid = true
    elseif is_solid then
        configured()
        is_solid = false
    end
end

local group = vim.api.nvim_create_augroup("KittyTheme", { clear = true })
vim.api.nvim_create_autocmd({ "VimEnter", "VimResume" }, {
    group = group,
    callback = apply,
})
vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ThemeApplied",
    callback = apply,
})
vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
    group = group,
    callback = function()
        if not is_solid then return end
        -- wait, so the reset still lands when nvim is exiting
        for _, job in ipairs(configured()) do job:wait(1000) end
        is_solid = false
    end,
})
