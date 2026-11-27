-- GraphQL across the stack: links the schema, the Java/Kotlin resolvers (DGS /
-- Spring GraphQL, including nested fetchers) and the frontend operations, and
-- routes it through the language servers so usages/implementations
-- (<leader>gu/<leader>gi, Trouble, the usage counts above methods) follow it:
--
--   Java resolver   references -> frontend usages, implementation -> schema field
--                   (added to jdtls's answers)
--   schema field    references -> frontend usages, implementation -> Java resolver
--   operation field references -> frontend usages, implementation -> Java resolver
--   TS document     implementation -> the Java resolvers the operation hits
--                   (GetCoreSettingsDocument, ...Query, ...Fragment, ...)
--                   (these three come from a small in-process "graphql-bridge" server)
--
-- Schema fields also get "3 usages · CoreLogController" at the end of the line.
-- A frontend usage is a component using the operation's generated code; nested
-- fields count through the operations/fragments that select them.
local M = {}

local caches = {} -- project root -> { schema, resolvers, frontend }, each built on first use

local function project_root(buf)
    return vim.fs.root(buf, { "settings.gradle.kts", "settings.gradle", "pom.xml", ".git" })
end

local function cache(root)
    caches[root] = caches[root] or {}
    return caches[root]
end

local function rg(args)
    return vim.fn.systemlist(vim.list_extend({ "rg" }, args))
end

local function location(file, lnum, col, len)
    return {
        uri = vim.uri_from_fname(file),
        range = { start = { line = lnum - 1, character = col }, ["end"] = { line = lnum - 1, character = col + len } },
    }
end

-- Schema -----------------------------------------------------------------------

local function base_type(s)
    return (s:gsub("@.*", ""):gsub("[%[%]!%s,]", ""))
end

---Every field of every `type`/`interface` (and their `extend`s):
---fields["type.field"] = { file, lnum, col, parent, field, key, type (named return type) }
---types["type"] = { name, fields = { ["field"] = entry } }, by_file[file][lnum] = key
local function schema(root)
    local c = cache(root)
    if c.schema then return c.schema end
    local s = { fields = {}, types = {}, by_file = {} }
    for _, file in ipairs(rg({ "--files", "-g", "*.graphql", "-g", "*.graphqls", root })) do
        local current, pending, in_description = nil, nil, false
        for lnum, raw in ipairs(vim.fn.readfile(file)) do
            local _, quotes = raw:gsub('"""', "")
            if quotes % 2 == 1 then
                in_description = not in_description
            elseif not in_description and not raw:match('^%s*"') then
                local line = raw:gsub("#.*", "")
                local type_name = line:match("^%s*extend%s+type%s+([%w_]+)") or line:match("^%s*type%s+([%w_]+)")
                    or line:match("^%s*extend%s+interface%s+([%w_]+)") or line:match("^%s*interface%s+([%w_]+)")
                if type_name then
                    current, pending = type_name, nil
                    local t = s.types[type_name:lower()] or { name = type_name, fields = {} }
                    s.types[type_name:lower()] = t
                    if not line:match("^%s*extend") then -- where it's defined, for go-to-definition
                        t.file, t.lnum, t.col = file, lnum, (line:find(type_name, 1, true) or 1) - 1
                    end
                elseif line:match("^}") then
                    current, pending = nil, nil
                elseif pending then
                    -- arguments over several lines: the type follows the closing paren
                    local t = line:match("%)%s*:%s*(.+)")
                    if t then pending.type, pending = base_type(t), nil end
                elseif current then
                    local field = line:match("^%s*([%w_]+)%s*[%(:]")
                    if field then
                        local key = (current .. "." .. field):lower()
                        local entry = {
                            file = file, lnum = lnum, col = (line:find(field, 1, true) or 1) - 1,
                            parent = current, field = field, key = key,
                        }
                        local t = line:match("%)%s*:%s*(.+)") or line:match("^%s*[%w_]+%s*:%s*(.+)")
                        if t then
                            entry.type = base_type(t)
                        elseif line:find("(", 1, true) then
                            pending = entry
                        end
                        s.fields[key] = entry
                        s.types[current:lower()].fields[field:lower()] = entry
                        s.by_file[file] = s.by_file[file] or {}
                        s.by_file[file][lnum] = key
                    end
                end
            end
        end
    end
    c.schema = s
    return s
end

-- Resolvers --------------------------------------------------------------------

local roots = {
    DgsQuery = "Query", QueryMapping = "Query",
    DgsMutation = "Mutation", MutationMapping = "Mutation",
    DgsSubscription = "Subscription", SubscriptionMapping = "Subscription",
    DgsData = false, SchemaMapping = false, BatchMapping = false, -- type comes from the args
}

-- value of `key = ...` in annotation args: a "string" or a constant like
-- CALL.TYPE_NAME / DgsConstants.QUERY.Foo (reduced to the meaningful part)
local function arg(args, key)
    local v = args:match(key .. '%s*=%s*"([^"]*)"')
    if v then return v end
    local const = args:match(key .. "%s*=%s*([%w_%.]+)")
    if not const then return nil end
    local parts = vim.split(const, ".", { plain = true })
    if parts[#parts] == "TYPE_NAME" then return parts[#parts - 1] end
    return parts[#parts]
end

-- Schema type and field a resolver's annotations (`header`) point at
local function target(header, method)
    for name, args in header:gmatch("@([%w_]+)%s*(%b())") do
        if roots[name] ~= nil then
            return roots[name] or arg(args, "parentType") or arg(args, "typeName"),
                arg(args, "field") or args:match('^%(%s*"([^"]*)"') or method
        end
    end
    for name in header:gmatch("@([%w_]+)") do
        if roots[name] then return roots[name], method end
    end
end

-- Method name declared on a line, ignoring annotations on it
local function method_name(line)
    local sig = line:gsub("@[%w_%.]+%s*%b()", ""):gsub("@[%w_%.]+", "")
    return sig:match("([%w_]+)%s*%(")
end

---resolvers["type.field"] = { { file, lnum, col, method, class }, ... }
local function resolvers(root)
    local c = cache(root)
    if c.resolvers then return c.resolvers end
    local r, files = {}, {}
    local pattern = "@(" .. table.concat(vim.tbl_keys(roots), "|") .. ")\\b"
    for _, hit in ipairs(rg({ "-n", "--no-heading", "-e", pattern, "-g", "*.java", "-g", "*.kt", root })) do
        local file, lnum = hit:match("^(.-):(%d+):")
        if file then
            files[file] = files[file] or {}
            table.insert(files[file], tonumber(lnum))
        end
    end
    for file, lnums in pairs(files) do
        local lines = vim.fn.readfile(file)
        for _, a in ipairs(lnums) do
            for j = a, math.min(a + 10, #lines) do
                local name = method_name(lines[j])
                if name then
                    local t, f = target(table.concat(vim.list_slice(lines, a, j), " "), name)
                    if t and f then
                        local key = (t .. "." .. f):lower()
                        r[key] = r[key] or {}
                        table.insert(r[key], {
                            file = file, lnum = j, col = (lines[j]:find(name, 1, true) or 1) - 1,
                            method = name, class = vim.fn.fnamemodify(file, ":t:r"),
                        })
                    end
                    break
                end
            end
        end
    end
    c.resolvers = r
    return r
end

-- Frontend ---------------------------------------------------------------------

-- generated names codegen derives from an operation/fragment name
local suffixes = {
    "QueryVariables", "MutationVariables", "SubscriptionVariables", "FragmentDoc",
    "Fragment", "Document", "Query", "Mutation", "Subscription",
}
local op_roots = { query = "Query", mutation = "Mutation", subscription = "Subscription" }

---Operations and fragments in a .graphql document, each with the fields it
---selects ("Type.field", following the schema's field types down nested
---selections and inline fragments) and the fragments it spreads
local function parse_documents(file, lines, types)
    local entries, entry = {}, nil
    local depth, paren, stack, pending = 0, 0, {}, nil
    local function new_entry(kind, name, lnum)
        entry = { kind = kind, name = name, file = file, lnum = lnum, fields = {}, spreads = {} }
        table.insert(entries, entry)
    end
    for lnum, raw in ipairs(lines) do
        local code = raw:gsub("#.*", ""):gsub('"[^"]*"', '""')
        if depth == 0 and paren == 0 then
            local keyword, name = code:match("^%s*(%a+)%s*([%w_]*)")
            if keyword and op_roots[keyword] then
                new_entry(keyword, name, lnum)
                pending = op_roots[keyword]
            elseif keyword == "fragment" then
                new_entry("fragment", name, lnum)
                pending = code:match("%f[%w]on%s+([%w_]+)")
            elseif code:match("^%s*{") then
                new_entry("query", "", lnum) -- `{ ... }` shorthand
                pending = "Query"
            end
        elseif depth >= 1 and paren == 0 and entry then
            local on = code:match("^%s*%.%.%.%s*on%s+([%w_]+)")
            local spread = not on and code:match("^%s*%.%.%.%s*([%w_]+)")
            if on then
                pending = on
            elseif spread then
                entry.spreads[spread:lower()] = true
            else
                local field = code:match("^%s*[%w_]+%s*:%s*([%w_]+)") or code:match("^%s*([%w_]+)")
                local parent = stack[depth]
                pending = nil
                if field and parent then
                    table.insert(entry.fields, {
                        key = (parent .. "." .. field):lower(), lnum = lnum,
                        col = (code:find(field, 1, true) or 1) - 1, len = #field,
                    })
                    local t = types[parent:lower()]
                    local f = t and t.fields[field:lower()]
                    pending = f and f.type
                end
            end
        end
        for ch in code:gmatch("[{}()]") do
            if ch == "(" then
                paren = paren + 1
            elseif ch == ")" then
                paren = paren - 1
            elseif paren == 0 and ch == "{" then
                depth = depth + 1
                stack[depth], pending = pending, nil
            elseif paren == 0 and ch == "}" then
                stack[depth] = nil
                depth = math.max(depth - 1, 0)
                if depth == 0 then entry = nil end
            end
        end
    end
    return entries
end

-- Where components use each operation's/fragment's generated code (imports aside),
-- keyed by the lowercased name since codegen capitalises it
-- (`query getCoreSettings` -> GetCoreSettingsDocument, GetCoreSettingsQuery, ...)
local function component_uses(root)
    local uses = {}
    local hits = rg({
        "-n", "--no-heading", "-e", "[A-Za-z0-9_]+(" .. table.concat(suffixes, "|") .. ")\\b",
        "-g", "*.ts", "-g", "*.tsx", "-g", "!**/__generated__/**", root,
    })
    for _, hit in ipairs(hits) do
        local file, lnum, text = hit:match("^(.-):(%d+):(.*)$")
        local is_import = text and (text:match("^%s*import") or text:match("from%s+[\"']") or text:match("^%s*[%w_]+,?%s*$"))
        if text and not is_import then
            local init = 1
            while true do
                local s, e, ident = text:find("([%w_]+)", init)
                if not s then break end
                for _, suffix in ipairs(suffixes) do
                    if #ident > #suffix and ident:sub(-#suffix) == suffix then
                        local key = ident:sub(1, -#suffix - 1):lower()
                        uses[key] = uses[key] or {}
                        table.insert(uses[key], location(file, tonumber(lnum), s - 1, #ident))
                        break
                    end
                end
                init = e + 1
            end
        end
    end
    return uses
end

---usages["type.field"] = frontend locations (one per line),
---by_name["operation or fragment"] = parsed entry
local function frontend(root)
    local c = cache(root)
    if c.frontend then return c.frontend end
    local s = schema(root)
    local docs = component_uses(root)
    local entries, by_name, spread_by = {}, {}, {}
    for _, file in ipairs(rg({ "--files", "-g", "*.graphql", root })) do
        if not s.by_file[file] then
            for _, e in ipairs(parse_documents(file, vim.fn.readfile(file), s.types)) do
                table.insert(entries, e)
                if e.name ~= "" then by_name[e.name:lower()] = e end
                for name in pairs(e.spreads) do
                    spread_by[name] = spread_by[name] or {}
                    table.insert(spread_by[name], e)
                end
            end
        end
    end

    -- components using an operation; for a fragment also those using the
    -- operations (and fragments) that spread it
    local function used_in(e, seen)
        if seen[e] then return {} end
        seen[e] = true
        local out = vim.list_extend({}, e.name ~= "" and docs[e.name:lower()] or {})
        if e.kind == "fragment" then
            for _, parent in ipairs(spread_by[e.name:lower()] or {}) do
                vim.list_extend(out, used_in(parent, seen))
            end
        end
        return out
    end

    local usages = {}
    for _, e in ipairs(entries) do
        local targets = used_in(e, {})
        for _, f in ipairs(e.fields) do
            usages[f.key] = usages[f.key] or {}
            -- not used by any component yet: the selection itself
            vim.list_extend(usages[f.key], #targets > 0 and targets or { location(e.file, f.lnum, f.col, f.len) })
        end
    end
    for key, locs in pairs(usages) do
        local seen, unique = {}, {}
        for _, l in ipairs(locs) do
            local id = l.uri .. ":" .. l.range.start.line
            if not seen[id] then
                seen[id] = true
                table.insert(unique, l)
            end
        end
        usages[key] = unique
    end
    c.frontend = { usages = usages, by_name = by_name }
    return c.frontend
end

-- Java side ----------------------------------------------------------------------

-- Annotation text (joined) and method name for the declaration whose name is on
-- `line` (0-based): looks at the lines directly above it
local function declaration(buf, line)
    local lines = vim.api.nvim_buf_get_lines(buf, math.max(0, line - 15), line + 1, false)
    local first = #lines
    for i = #lines - 1, 1, -1 do
        if lines[i]:match("[;{}]%s*$") then break end
        first = i
    end
    return table.concat(vim.list_slice(lines, first, #lines), " "), method_name(lines[#lines])
end

---Schema field for the resolver declared on `line` (0-based) of a Java/Kotlin buffer, or nil.
function M.resolve(buf, line)
    local root = project_root(buf)
    if not root then return nil end
    local t, f = target(declaration(buf, line))
    return t and f and schema(root).fields[(t .. "." .. f):lower()] or nil
end

-- Resolver at the cursor: the enclosing method (treesitter), else the cursor line
local function resolver_at_cursor()
    local node = vim.treesitter.get_node()
    while node and not node:type():match("method_declaration") and node:type() ~= "function_declaration" do
        node = node:parent()
    end
    if node then
        local name = node:field("name")[1]
        if name then return (name:range()) end
    end
    return vim.api.nvim_win_get_cursor(0)[1] - 1
end

function M.goto_definition()
    local def = M.resolve(0, resolver_at_cursor())
    if not def then
        vim.notify("No GraphQL schema definition found for this method", vim.log.levels.INFO)
        return
    end
    vim.cmd("normal! m'") -- so <C-o> comes back
    vim.cmd.edit(vim.fn.fnameescape(def.file))
    vim.api.nvim_win_set_cursor(0, { def.lnum, def.col })
    vim.cmd("normal! zz")
end

-- Extra results for a jdtls references/implementation request on a resolver
local function java_locations(method, params, buf)
    local def = M.resolve(buf, params.position.line)
    if not def then return {} end
    if method == "textDocument/implementation" then
        return { location(def.file, def.lnum, def.col, #def.field) }
    end
    return frontend(project_root(buf)).usages[def.key] or {}
end

-- graphql-bridge (schema, operations, TS) --------------------------------------------

local function word_at(buf, pos)
    local line = vim.api.nvim_buf_get_lines(buf, pos.line, pos.line + 1, false)[1] or ""
    local s, e = pos.character + 1, pos.character + 1
    while s > 1 and line:sub(s - 1, s - 1):match("[%w_]") do s = s - 1 end
    while e <= #line and line:sub(e, e):match("[%w_]") do e = e + 1 end
    return line:sub(s, e - 1)
end

-- Schema fields a request position is about
local function keys_at(root, buf, pos)
    local s = schema(root)
    local file = vim.api.nvim_buf_get_name(buf)
    if vim.bo[buf].filetype == "graphql" then
        if s.by_file[file] then
            local key = s.by_file[file][pos.line + 1]
            return key and { key } or {}
        end
        for _, e in ipairs(parse_documents(file, vim.api.nvim_buf_get_lines(buf, 0, -1, false), s.types)) do
            for _, f in ipairs(e.fields) do
                if f.lnum == pos.line + 1 then return { f.key } end
            end
        end
        return {}
    end
    -- TS: a generated name -> every field the operation/fragment selects
    local word = word_at(buf, pos)
    for _, suffix in ipairs(suffixes) do
        if #word > #suffix and word:sub(-#suffix) == suffix then
            local e = frontend(root).by_name[word:sub(1, -#suffix - 1):lower()]
            return e and vim.tbl_map(function(f) return f.key end, e.fields) or {}
        end
    end
    return {}
end

-- Go to definition in .graphql files: a fragment spread -> the fragment, a field
-- in an operation -> its schema field, a type name -> the schema type
local function definition(root, buf, pos)
    local s = schema(root)
    local word = word_at(buf, pos)
    if word == "" then return {} end
    local line = vim.api.nvim_buf_get_lines(buf, pos.line, pos.line + 1, false)[1] or ""
    local fragment = line:match("^%s*%.%.%.%s*([%w_]+)") == word and word ~= "on" and frontend(root).by_name[word:lower()]
    if fragment and fragment.kind == "fragment" then
        local text = vim.fn.readfile(fragment.file)[fragment.lnum] or ""
        return { location(fragment.file, fragment.lnum, (text:find(fragment.name, 1, true) or 1) - 1, #fragment.name) }
    end
    if not s.by_file[vim.api.nvim_buf_get_name(buf)] then
        local key = keys_at(root, buf, pos)[1]
        local field = key and s.fields[key]
        if field and field.field == word then
            return { location(field.file, field.lnum, field.col, #field.field) }
        end
    end
    local t = s.types[word:lower()]
    if t and t.file then return { location(t.file, t.lnum, t.col, #t.name) } end
    return {}
end

local function bridge_locations(method, params)
    local buf = vim.uri_to_bufnr(params.textDocument.uri)
    local root = project_root(buf)
    if not root then return {} end
    if method == "textDocument/definition" then
        return vim.bo[buf].filetype == "graphql" and definition(root, buf, params.position) or {}
    end
    local out = {}
    for _, key in ipairs(keys_at(root, buf, params.position)) do
        if method == "textDocument/implementation" then
            for _, r in ipairs(resolvers(root)[key] or {}) do
                table.insert(out, location(r.file, r.lnum, r.col, #r.method))
            end
        elseif vim.bo[buf].filetype == "graphql" then -- TS references are vtsls's
            vim.list_extend(out, frontend(root).usages[key] or {})
        end
    end
    return out
end

-- In-process language server answering references/implementation/definition
local function bridge_server(dispatchers)
    local closing, id = false, 0
    return {
        request = function(method, params, callback)
            id = id + 1
            local result
            if method == "initialize" then
                result = { capabilities = { referencesProvider = true, implementationProvider = true, definitionProvider = true } }
            elseif method == "textDocument/references" or method == "textDocument/implementation"
                or method == "textDocument/definition" then
                local ok, res = pcall(bridge_locations, method, params)
                result = ok and res or {}
            end
            vim.schedule(function() callback(nil, result) end)
            return true, id
        end,
        notify = function(method)
            if method == "exit" then dispatchers.on_exit(0, 15) end
            return true
        end,
        is_closing = function() return closing end,
        terminate = function() closing = true end,
    }
end

-- Schema hints -------------------------------------------------------------------

local hint_ns = vim.api.nvim_create_namespace("graphql_schema_hints")

-- "3 usages · CoreLogController" at the end of each schema field
local function render_hints(buf)
    vim.api.nvim_buf_clear_namespace(buf, hint_ns, 0, -1)
    local root = project_root(buf)
    local fields = root and schema(root).by_file[vim.api.nvim_buf_get_name(buf)]
    if not fields then return end
    local usages, res = frontend(root).usages, resolvers(root)
    local count = vim.api.nvim_buf_line_count(buf)
    for lnum, key in pairs(fields) do
        if lnum <= count then
            local n = #(usages[key] or {})
            local text = n == 0 and "no usages" or ("%d usage%s"):format(n, n == 1 and "" or "s")
            local r = res[key] and res[key][1]
            if r then text = text .. " · " .. r.class end
            vim.api.nvim_buf_set_extmark(buf, hint_ns, lnum - 1, 0, {
                virt_text = { { "  " .. text, "LspInlayHint" } },
                virt_text_pos = "eol",
            })
        end
    end
end

-- Wiring -----------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("GraphqlSchema", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = { "*.graphql", "*.graphqls", "*.ts", "*.tsx", "*.java", "*.kt" },
    callback = function(ev)
        local root = project_root(ev.buf)
        if not root or not caches[root] then return end
        local c = caches[root]
        if ev.match:match("%.graphqls?$") then
            c.schema, c.frontend = nil, nil
            render_hints(ev.buf)
        elseif ev.match:match("%.tsx?$") then
            c.frontend = nil
        else
            c.resolvers = nil
        end
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = { "*.graphql", "*.graphqls" },
    callback = function(ev) render_hints(ev.buf) end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "java", "kotlin" },
    callback = function(ev)
        vim.keymap.set("n", "<leader>gq", M.goto_definition, { buffer = ev.buf, desc = "GraphQL schema definition" })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "graphql", "typescript", "typescriptreact" },
    callback = function(ev)
        local root = project_root(ev.buf)
        if not root or vim.api.nvim_buf_get_name(ev.buf) == "" then return end
        if next(schema(root).fields) == nil then return end -- no GraphQL schema here
        vim.lsp.start({ name = "graphql-bridge", cmd = bridge_server, root_dir = root }, { bufnr = ev.buf })
    end,
})

-- jdtls: add the frontend usages and the schema field to its answers for resolvers
vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client or client.name ~= "jdtls" or client._graphql_bridge then return end
        client._graphql_bridge = true
        local request = client.request
        client.request = function(self, method, params, handler, bufnr)
            if (method == "textDocument/references" or method == "textDocument/implementation")
                and params and params.position then
                local inner = handler or client.handlers[method] or vim.lsp.handlers[method]
                handler = function(err, result, ctx, config)
                    if not err then
                        local buf = vim.uri_to_bufnr(params.textDocument.uri)
                        local ok, extra = pcall(java_locations, method, params, buf)
                        if ok and #extra > 0 then
                            result = vim.list_extend(vim.deepcopy(result or {}), extra)
                        end
                    end
                    return inner(err, result, ctx, config)
                end
            end
            return request(self, method, params, handler, bufnr)
        end
    end,
})

M._index = { schema = schema, resolvers = resolvers, frontend = frontend } -- for testing
return M
