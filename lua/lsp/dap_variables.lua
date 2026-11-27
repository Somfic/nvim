-- Snacks picker for DAP variables with deep-expanded preview. <CR> adds a watch.
local M = {}

local MAX_DEPTH = 4

function M.pick()
    local ok_dap, dap = pcall(require, "dap")
    if not ok_dap then return end
    local session = dap.session()
    if not session or not session.current_frame then
        vim.notify("No active DAP session / stopped frame", vim.log.levels.WARN)
        return
    end

    local function collect(ref, depth, path, scope_name, out, done)
        session:request("variables", { variablesReference = ref }, function(_, resp)
            if not (resp and resp.variables) then done() return end
            local remaining = #resp.variables
            if remaining == 0 then done() return end
            for _, v in ipairs(resp.variables) do
                table.insert(out, {
                    scope = scope_name,
                    name = v.name,
                    path = path,
                    depth = depth,
                    value = v.value or "",
                    type = v.type or "",
                    ref = v.variablesReference or 0,
                })
                if v.variablesReference and v.variablesReference > 0 and depth < MAX_DEPTH then
                    collect(v.variablesReference, depth + 1, path .. "." .. v.name, scope_name, out, function()
                        remaining = remaining - 1
                        if remaining == 0 then done() end
                    end)
                else
                    remaining = remaining - 1
                    if remaining == 0 then done() end
                end
            end
        end)
    end

    session:request("scopes", { frameId = session.current_frame.id }, function(_, scope_resp)
        if not scope_resp or not scope_resp.scopes then return end
        local entries = {}
        local pending = #scope_resp.scopes
        for _, scope in ipairs(scope_resp.scopes) do
            collect(scope.variablesReference, 0, scope.name, scope.name, entries, function()
                pending = pending - 1
                if pending == 0 then
                    vim.schedule(function() M._open(session, entries) end)
                end
            end)
        end
    end)
end

local ns = vim.api.nvim_create_namespace("dap_var_preview")

-- highlight [s, e) on a 0-based line; e = -1 means to the end of the line
local function hl(buf, group, line, s, e)
    if e == -1 then e = #(vim.api.nvim_buf_get_lines(buf, line, line + 1, false)[1] or "") end
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, line, s, { end_col = e, hl_group = group })
end

local function scope_hl(scope)
    local s = scope:lower()
    if s:match("local") then return "Function" end
    if s:match("static") or s:match("arg") then return "Type" end
    if s:match("global") or s:match("registers") then return "Constant" end
    return "Comment"
end

-- Infer a highlight group for a scalar token
local function token_hl(tok)
    if tok == "true" or tok == "false" then return "Boolean" end
    if tok:match("^%-?%d") then return "Number" end
    if tok:sub(1, 1) == '"' or tok:sub(1, 1) == "'" then return "String" end
    if tok:match("^Some") or tok:match("^None") or tok:match("^Ok") or tok:match("^Err")
        or tok:match("^[A-Z][%w_]*$") then return "Special" end
    return "Normal"
end

-- Split a value string into { {text, hl}, ... }: punctuation dim, `name:`/`name =` as
-- identifier, scalars by inferred type
local function colorize_value(s)
    local out = {}
    local i = 1
    while i <= #s do
        local c = s:sub(i, i)
        if c:match("[{}%[%](),:;]") then
            table.insert(out, { c, "NonText" })
            i = i + 1
        elseif c == " " then
            table.insert(out, { " ", "Normal" })
            i = i + 1
        else
            local name_end = s:find("[^%w_%.%-\"']", i)
            local token = s:sub(i, (name_end or #s + 1) - 1)
            if token == "" then
                table.insert(out, { c, "Normal" })
                i = i + 1
            else
                local nxt_pos = s:find("%S", name_end or #s + 1)
                local nxt = nxt_pos and s:sub(nxt_pos, nxt_pos)
                table.insert(out, { token, (nxt == ":" or nxt == "=") and "Identifier" or token_hl(token) })
                i = i + #token
            end
        end
    end
    return out
end

local function highlight_value_line(buf, lineno, line)
    local col = 0
    for _, seg in ipairs(colorize_value(line)) do
        if seg[2] ~= "Normal" then hl(buf, seg[2], lineno, col, col + #seg[1]) end
        col = col + #seg[1]
    end
end

-- Render the preview: header, value, and (once fetched) children
local function render(buf, v, header, children)
    local lines = vim.deepcopy(header)
    for line in vim.gsplit(v.value, "\n", { plain = true }) do
        table.insert(lines, "  " .. line)
    end
    local children_start
    if children and #children > 0 then
        table.insert(lines, "")
        table.insert(lines, "Children:")
        children_start = #lines
        vim.list_extend(lines, children)
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i = 0, 2 do hl(buf, "Comment", i, 0, 6) end
    hl(buf, scope_hl(v.scope), 0, 7, -1)
    hl(buf, "Identifier", 1, 7, -1)
    hl(buf, "Type", 2, 7, -1)
    hl(buf, "Comment", 4, 0, -1)
    for i = #header, #lines - 1 do
        if i ~= (children_start or 0) - 1 then highlight_value_line(buf, i, lines[i + 1]) end
    end
    if children_start then hl(buf, "Comment", children_start - 1, 0, -1) end
end

function M._open(session, entries)
    local items = {}
    for _, v in ipairs(entries) do
        table.insert(items, {
            text = (v.path or "") .. " " .. v.name .. " " .. (v.value or ""),
            var = v,
        })
    end

    Snacks.picker({
        title = "DAP Variables",
        items = items,
        sort = { fields = { "score:desc", "idx" } }, -- keep the tree order for equal scores
        format = function(item)
            local v = item.var
            local short = (v.value or ""):gsub("\n", " ")
            if #short > 80 then short = short:sub(1, 80) .. "…" end
            local ret = {}
            if not v.scope:lower():match("local") then
                table.insert(ret, { "[" .. v.scope:sub(1, 3):upper() .. "] ", scope_hl(v.scope) })
            end
            if (v.depth or 0) > 0 then
                table.insert(ret, { string.rep("  ", v.depth) .. "└ ", "NonText" })
            end
            table.insert(ret, { v.name, "Identifier" })
            table.insert(ret, { " = ", "NonText" })
            vim.list_extend(ret, colorize_value(short))
            return ret
        end,
        preview = function(ctx)
            local v = ctx.item.var
            local buf = ctx.buf
            ctx.preview:reset()
            ctx.preview:set_title("Value")
            local header = { "Scope: " .. v.scope, "Name:  " .. v.name, "Type:  " .. v.type, "", "Value:" }
            render(buf, v, header)
            if v.ref == 0 then return end

            -- fetch children up to 3 levels deep, re-rendering as responses arrive
            local children = {}
            local function still_current()
                return vim.api.nvim_buf_is_valid(buf) and ctx.picker:current() == ctx.item
            end
            local function walk(ref, depth)
                session:request("variables", { variablesReference = ref }, function(_, resp)
                    if not (resp and resp.variables) then return end
                    for _, child in ipairs(resp.variables) do
                        table.insert(children, string.rep("  ", depth) .. child.name .. " = " .. (child.value or ""))
                        if child.variablesReference and child.variablesReference > 0 and depth < 3 then
                            walk(child.variablesReference, depth + 1)
                        end
                    end
                    vim.schedule(function()
                        if still_current() then render(buf, v, header, children) end
                    end)
                end)
            end
            walk(v.ref, 1)
        end,
        confirm = function(picker, item)
            picker:close()
            if item then require("dapui").elements.watches.add(item.var.name) end
        end,
    })
end

return M
