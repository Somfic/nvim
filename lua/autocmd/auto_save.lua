-- Auto save: 1s after you stop editing, and right away when leaving the buffer or
-- nvim. Formatting happens in conform's format_on_save (BufWritePre).
local DELAY_MS = 1000

local group = vim.api.nvim_create_augroup("AutoSave", { clear = true })
local timers = {} -- buf -> uv timer

-- only real files: skips oil (acwrite), terminals, prompts, scratch buffers
local function saveable(buf)
    return vim.api.nvim_buf_is_valid(buf)
        and vim.bo[buf].buftype == ""
        and vim.bo[buf].modifiable
        and not vim.bo[buf].readonly
        and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function cancel(buf)
    local timer = timers[buf]
    if timer then
        timer:stop()
        timer:close()
        timers[buf] = nil
    end
end

local function save(buf)
    cancel(buf)
    if not saveable(buf) or not vim.bo[buf].modified then return end
    -- writing mid-insert would move the cursor via formatting; InsertLeave saves instead
    if buf == vim.api.nvim_get_current_buf() and vim.fn.mode():match("^[iR]") then return end
    vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent! lockmarks update")
    end)
end

local function schedule_save(buf)
    cancel(buf)
    local timer = vim.uv.new_timer()
    timers[buf] = timer
    timer:start(DELAY_MS, 0, vim.schedule_wrap(function() save(buf) end))
end

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
    group = group,
    callback = function(ev)
        if saveable(ev.buf) then schedule_save(ev.buf) end
    end,
})

-- typing again postpones a pending save
vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = function(ev) cancel(ev.buf) end,
})

vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "VimLeavePre" }, {
    group = group,
    callback = function(ev) save(ev.buf) end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    callback = function(ev) cancel(ev.buf) end,
})
