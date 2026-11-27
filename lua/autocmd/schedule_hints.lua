-- Plain-language hint at the end of Spring @Scheduled lines (Java/Kotlin):
--   @Scheduled(cron = "0 15 15 * * ?")             every day at 15:15
--   @Scheduled(fixedDelay = 1000 * 60 * 30, initialDelay = 60000)
--                                                   every 30 minutes after the previous run, first after 1 minute
local ns = vim.api.nvim_create_namespace("schedule_hints")

local days = { [0] = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
local day_names = { SUN = "Sunday", MON = "Monday", TUE = "Tuesday", WED = "Wednesday", THU = "Thursday", FRI = "Friday", SAT = "Saturday" }
local month_names = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
local macros = {
    ["@yearly"] = "every year on January 1st at 00:00", ["@annually"] = "every year on January 1st at 00:00",
    ["@monthly"] = "on the 1st of every month at 00:00", ["@weekly"] = "every Sunday at 00:00",
    ["@daily"] = "every day at 00:00", ["@midnight"] = "every day at 00:00", ["@hourly"] = "every hour",
}

local function plural(n, unit) return ("%s %s%s"):format(n, unit, n == 1 and "" or "s") end

local function duration(ms)
    for _, u in ipairs({ { 86400000, "day" }, { 3600000, "hour" }, { 60000, "minute" }, { 1000, "second" } }) do
        if ms >= u[1] and ms % u[1] == 0 then return plural(ms / u[1], u[2]) end
    end
    if ms >= 1000 then return plural(ms / 1000, "second") end
    return plural(ms, "millisecond")
end

local function is_any(f) return f == "*" or f == "?" end

local function day_of_week(f)
    local function name(d) return day_names[d:upper()] or days[tonumber(d)] or d end
    local a, b = f:match("^(%w+)%-(%w+)$")
    if a then return name(a) .. " to " .. name(b) end
    return table.concat(vim.tbl_map(name, vim.split(f, ",", { plain = true })), ", ")
end

-- Spring cron: second minute hour day-of-month month day-of-week
local function describe_cron(expr)
    expr = vim.trim(expr)
    if macros[expr] then return macros[expr] end
    local f = vim.split(expr, "%s+")
    if #f ~= 6 then return nil end
    local s, m, h, dom, mon, dow = unpack(f)
    local num = function(x) return x:match("^%d+$") and tonumber(x) end
    local step = function(x) return tonumber(x:match("^[%*0]/(%d+)$")) end

    local when
    if num(s) and num(m) and num(h) then
        when = ("at %02d:%02d"):format(num(h), num(m)) .. (num(s) ~= 0 and (":%02d"):format(num(s)) or "")
    elseif num(s) and num(m) and step(h) then
        when = ("every %s at :%02d"):format(plural(step(h), "hour"), num(m))
    elseif num(s) and num(m) and is_any(h) then
        when = num(m) == 0 and "every hour" or ("every hour at :%02d"):format(num(m))
    elseif num(s) and step(m) and is_any(h) then
        when = "every " .. plural(step(m), "minute")
    elseif step(s) and is_any(m) and is_any(h) then
        when = "every " .. plural(step(s), "second")
    elseif num(s) and is_any(m) and is_any(h) then
        when = "every minute"
    else
        return nil
    end

    local days_part
    if is_any(dom) and is_any(dow) then
        days_part = when:match("^at") and "every day" or nil
    elseif not is_any(dow) and is_any(dom) then
        days_part = "every " .. day_of_week(dow)
    elseif num(dom) and is_any(dow) then
        days_part = "on day " .. num(dom) .. " of the month"
    else
        return nil
    end
    local months = not is_any(mon) and (" in " .. (month_names[tonumber(mon)] or mon)) or ""
    return table.concat(vim.tbl_filter(function(x) return x end, { days_part, when }), " ") .. months
end

-- "1000 * 60 * 30" -> 1800000; only plain arithmetic is evaluated
local function number(expr)
    expr = expr:gsub("_", ""):gsub("(%d)[lL]", "%1")
    if not expr:match("^[%d%s%*%+%-/%(%)]+$") then return nil end
    local chunk = load("return " .. expr, "schedule", "t", {})
    local ok, value = pcall(chunk or function() end)
    return ok and type(value) == "number" and value or nil
end

local unit_ms = { NANOSECONDS = 1e-6, MICROSECONDS = 1e-3, MILLISECONDS = 1, SECONDS = 1000, MINUTES = 60000, HOURS = 3600000, DAYS = 86400000 }

local function describe(args)
    local cron = args:match('cron%s*=%s*"([^"]*)"')
    if cron then return not cron:find("${", 1, true) and describe_cron(cron) or nil end

    local unit = unit_ms[args:match("timeUnit%s*=%s*[%w%.]*%.(%u+)") or "MILLISECONDS"] or 1
    local function ms(key)
        local v = args:match(key .. "%s*=%s*([^,]+)")
        v = v and number(v)
        return v and v * unit
    end
    local rate, delay, initial = ms("fixedRate"), ms("fixedDelay"), ms("initialDelay")
    local text
    if rate then
        text = "every " .. duration(rate)
    elseif delay then
        text = "every " .. duration(delay) .. " after the previous run"
    else
        return nil
    end
    if initial and initial > 0 then text = text .. ", first after " .. duration(initial) end
    return text
end

-- "every 1 minute" -> "every minute"
local function readable(args)
    local text = describe(args)
    return text and (text:gsub("every 1 (%a+)", "every %1"))
end

local function refresh(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local args = line:match("@Scheduled%s*%((.*)%)")
        local text = args and readable(args)
        if text then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                virt_text = { { "  " .. text, "LspInlayHint" } },
                virt_text_pos = "eol",
            })
        end
    end
end

local group = vim.api.nvim_create_augroup("ScheduleHints", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
    group = group,
    pattern = { "*.java", "*.kt" },
    callback = function(ev) refresh(ev.buf) end,
})

return { describe = readable }
