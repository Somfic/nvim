-- Telescope picker for DAP variables with deep-expanded preview.
local M = {}

local function expand(session, ref, depth, out, prefix)
    if ref == 0 or depth > 3 then return end
    local co = coroutine.running()
    session:request("variables", { variablesReference = ref }, function(_, resp)
        if resp and resp.variables then
            for _, v in ipairs(resp.variables) do
                local indent = string.rep("  ", depth)
                table.insert(out, string.format("%s%s%s: %s", indent, prefix, v.name, v.value or ""))
                if v.variablesReference and v.variablesReference > 0 and depth < 3 then
                    expand(session, v.variablesReference, depth + 1, out, "")
                end
            end
        end
        if co then coroutine.resume(co) end
    end)
    if co then coroutine.yield() end
end

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

function M._open(session, entries)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local previewers = require("telescope.previewers")
    local entry_display = require("telescope.pickers.entry_display")

    local function scope_hl(scope)
        local s = scope:lower()
        if s:match("local") then return "Function" end
        if s:match("static") or s:match("arg") then return "Type" end
        if s:match("global") or s:match("registers") then return "Constant" end
        return "Comment"
    end

    local function value_hl(v)
        local t = (v.type or ""):lower()
        local val = v.value or ""
        if t:match("bool") or val == "true" or val == "false" then return "Boolean" end
        if t:match("int") or t:match("float") or t:match("num") or val:match("^%-?%d") then return "Number" end
        if t:match("str") or val:sub(1, 1) == '"' or val:sub(1, 1) == "'" then return "String" end
        if val:match("^[%w_]+%s*{") or val:match("^Some") or val:match("^None") or val:match("^Ok") or val:match("^Err") then
            return "Special"
        end
        return "Normal"
    end

    -- Tokenize a value string into { {text, hl}, ... } for colored display
    local function colorize_value(s)
        local out = {}
        local i = 1
        while i <= #s do
            local c = s:sub(i, i)
            if c == "{" or c == "}" or c == "[" or c == "]" or c == "(" or c == ")"
                or c == "," or c == ":" or c == ";" then
                table.insert(out, { c, "NonText" })
                i = i + 1
            elseif c == " " then
                table.insert(out, { " ", "Normal" })
                i = i + 1
            else
                local name_end = s:find("[^%w_%.%-]", i)
                local token = s:sub(i, (name_end or #s + 1) - 1)
                if token == "" then
                    table.insert(out, { c, "Normal" })
                    i = i + 1
                else
                    local nxt_pos = s:find("%S", (name_end or #s + 1))
                    local nxt = nxt_pos and s:sub(nxt_pos, nxt_pos)
                    local hl
                    if nxt == ":" or nxt == "=" then
                        hl = "Identifier"
                    elseif token == "true" or token == "false" then
                        hl = "Boolean"
                    elseif token:match("^%-?%d") then
                        hl = "Number"
                    elseif token:match("^[A-Z]") then
                        hl = "Special"
                    else
                        hl = "Normal"
                    end
                    table.insert(out, { token, hl })
                    i = i + #token
                end
            end
        end
        return out
    end

    pickers.new({}, {
        prompt_title = "  DAP Variables",
        finder = finders.new_table({
            results = entries,
            entry_maker = function(v)
                local short = (v.value or ""):gsub("\n", " ")
                if #short > 80 then short = short:sub(1, 80) .. "…" end
                local is_local = v.scope:lower():match("local") ~= nil
                return {
                    value = v,
                    display = function()
                        local segments = {}
                        if not is_local then
                            table.insert(segments, { "[" .. v.scope:sub(1, 3):upper() .. "]", scope_hl(v.scope) })
                            table.insert(segments, { " ", "Normal" })
                        end
                        local depth = v.depth or 0
                        if depth > 0 then
                            table.insert(segments, { string.rep("  ", depth) .. "└ ", "NonText" })
                        end
                        table.insert(segments, { v.name, "Identifier" })
                        table.insert(segments, { " = ", "NonText" })
                        for _, seg in ipairs(colorize_value(short)) do
                            table.insert(segments, seg)
                        end

                        local text = ""
                        local hls = {}
                        for _, seg in ipairs(segments) do
                            local start = #text
                            text = text .. seg[1]
                            table.insert(hls, { { start, #text }, seg[2] })
                        end
                        return text, hls
                    end,
                    ordinal = (v.path or "") .. " " .. v.name .. " " .. (v.value or ""),
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            title = "Value",
            define_preview = function(self, entry)
                local v = entry.value
                local vhl = value_hl(v)
                local header = {
                    "Scope: " .. v.scope,
                    "Name:  " .. v.name,
                    "Type:  " .. v.type,
                    "",
                    "Value:",
                }
                local value_start = #header
                local lines = vim.deepcopy(header)
                for line in vim.gsplit(v.value, "\n", { plain = true }) do
                    table.insert(lines, "  " .. line)
                end
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

                local ns = vim.api.nvim_create_namespace("dap_var_preview")
                vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns, 0, -1)
                -- Header label colors
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    0, 0, 6)
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    1, 0, 6)
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    2, 0, 6)
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, scope_hl(v.scope), 0, 7, -1)
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Identifier", 1, 7, -1)
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Type",       2, 7, -1)
                vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    4, 0, -1)
                for i = value_start, #lines - 1 do
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, vhl, i, 0, -1)
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

                -- Highlight structured values: braces/commas dim, `name:` or `name =` as identifier, scalars by inferred type
                local function highlight_value_line(lineno, line)
                    local i = 1
                    while i <= #line do
                        local c = line:sub(i, i)
                        if c == "{" or c == "}" or c == "[" or c == "]" or c == "(" or c == ")"
                            or c == "," or c == ":" or c == ";" then
                            vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "NonText", lineno, i - 1, i)
                            i = i + 1
                        elseif c == " " then
                            i = i + 1
                        else
                            -- Identifier followed by `:` or `=` (field name)
                            local name_end = line:find("[^%w_]", i)
                            local token = line:sub(i, (name_end or #line + 1) - 1)
                            if token ~= "" then
                                local next_non_space = line:find("%S", (name_end or #line + 1))
                                local nxt = next_non_space and line:sub(next_non_space, next_non_space)
                                if nxt == ":" or nxt == "=" then
                                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Identifier",
                                        lineno, i - 1, i - 1 + #token)
                                else
                                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, token_hl(token),
                                        lineno, i - 1, i - 1 + #token)
                                end
                                i = i + #token
                            else
                                i = i + 1
                            end
                        end
                    end
                end

                local function rerender(all_lines, children_start)
                    if not vim.api.nvim_buf_is_valid(self.state.bufnr) then return end
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, all_lines)
                    vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns, 0, -1)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    0, 0, 6)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    1, 0, 6)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    2, 0, 6)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, scope_hl(v.scope), 0, 7, -1)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Identifier", 1, 7, -1)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Type",       2, 7, -1)
                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",    4, 0, -1)
                    -- Value lines (between "Value:" and children)
                    for i = value_start, (children_start or #all_lines) - 1 do
                        highlight_value_line(i, all_lines[i + 1] or "")
                    end
                    if children_start then
                        vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Comment",
                            children_start - 1, 0, -1)
                        for i = children_start, #all_lines - 1 do
                            highlight_value_line(i, all_lines[i + 1] or "")
                        end
                    end
                end

                if v.ref > 0 then
                    session:request("variables", { variablesReference = v.ref }, function(_, resp)
                        if not (resp and resp.variables) then return end
                        local extra = { "", "Children:" }
                        local children_start_offset = #lines + 2 -- after "" and "Children:"
                        local function walk(children, depth)
                            if depth > 3 then return end
                            for _, child in ipairs(children) do
                                table.insert(extra, string.rep("  ", depth) ..
                                    child.name .. " = " .. (child.value or ""))
                                if child.variablesReference and child.variablesReference > 0 and depth < 3 then
                                    session:request("variables",
                                        { variablesReference = child.variablesReference }, function(_, cr)
                                            if cr and cr.variables then walk(cr.variables, depth + 1) end
                                            vim.schedule(function()
                                                rerender(vim.list_extend(vim.deepcopy(lines), extra), children_start_offset)
                                            end)
                                        end)
                                end
                            end
                        end
                        walk(resp.variables, 1)
                        vim.schedule(function()
                            rerender(vim.list_extend(vim.deepcopy(lines), extra), children_start_offset)
                        end)
                    end)
                end
            end,
        }),
        attach_mappings = function(_, map)
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            map({ "i", "n" }, "<cr>", function(bufnr)
                local entry = action_state.get_selected_entry()
                actions.close(bufnr)
                if entry and entry.value then
                    require("dapui").elements.watches.add(entry.value.name)
                end
            end)
            return true
        end,
    }):find()
end

return M
