return {
    {
        "Wansmer/symbol-usage.nvim",
        event = "LspAttach",
        keys = {
            {
                "<leader>uu",
                function()
                    local su = require("symbol-usage")
                    -- toggling back on keeps the old (idle) workers, so restart them
                    if su.toggle_globally() then
                        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                            if vim.api.nvim_buf_is_loaded(buf) then vim.api.nvim_buf_call(buf, su.refresh) end
                        end
                    end
                end,
                desc = "Toggle usages",
            },
        },
        config = function()
            local function h(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end

            -- One colour (the theme's comment colour), no background; redone on every
            -- theme switch
            local function set_highlights()
                vim.api.nvim_set_hl(0, "SymbolUsageContent", { fg = h("Comment").fg, italic = true })
            end
            set_highlights()
            vim.api.nvim_create_autocmd("ColorScheme", {
                group = vim.api.nvim_create_augroup("SymbolUsageHighlights", { clear = true }),
                callback = set_highlights,
            })

            local function text_format(symbol)
                local res = {}
                local function part(chunks)
                    if #res > 0 then table.insert(res, { " · ", "SymbolUsageContent" }) end
                    vim.list_extend(res, chunks)
                end

                if symbol.references then
                    local usage = symbol.references <= 1 and "usage" or "usages"
                    local num = symbol.references == 0 and "no" or symbol.references
                    part({ { ("%s %s"):format(num, usage), "SymbolUsageContent" } })
                end

                if symbol.definition then
                    part({
                        { "󰳽 ", "SymbolUsageContent" },
                        { symbol.definition .. " defs", "SymbolUsageContent" },
                    })
                end

                -- only where something implements it (interfaces, abstract methods, ...)
                if symbol.implementation and symbol.implementation > 0 then
                    local impl = symbol.implementation == 1 and "implementation" or "implementations"
                    part({
                        { "󰡱 ", "SymbolUsageContent" },
                        { ("%d %s"):format(symbol.implementation, impl), "SymbolUsageContent" },
                    })
                end

                if symbol.stacked_count > 0 then
                    part({
                        { " ", "SymbolUsageContent" },
                        { ("+%s"):format(symbol.stacked_count), "SymbolUsageContent" },
                    })
                end

                return res
            end

            -- Related problems: usages of the symbol that have an error on their line
            -- (e.g. calls broken by a signature change). The reference locations are
            -- captured in symbol_filter below, keyed by the symbol's request position.
            local references = {} -- "uri:line" -> reference locations

            local function related_problems(bufnr, line)
                local locs = references[vim.uri_from_bufnr(bufnr) .. ":" .. line]
                if not locs or #locs == 0 then return 0 end
                -- diagnostics live on buffers (servers like jdtls also publish them for
                -- files that aren't open); don't create buffers just to look
                local bufs = {}
                for _, b in ipairs(vim.api.nvim_list_bufs()) do
                    bufs[vim.uri_from_bufnr(b)] = b
                end
                local count = 0
                for _, loc in ipairs(locs) do
                    local b = bufs[loc.uri]
                    if b and #vim.diagnostic.get(b, {
                            lnum = loc.range.start.line,
                            severity = vim.diagnostic.severity.ERROR,
                        }) > 0 then
                        count = count + 1
                    end
                end
                return count
            end

            -- Methods the framework calls, so "no usages" would be misleading:
            -- annotation -> what to show instead
            local entry_points = {
                DgsQuery = "GraphQL query", QueryMapping = "GraphQL query",
                DgsMutation = "GraphQL mutation", MutationMapping = "GraphQL mutation",
                DgsData = "GraphQL field", SchemaMapping = "GraphQL field", BatchMapping = "GraphQL field",
                DgsSubscription = "GraphQL subscription", SubscriptionMapping = "GraphQL subscription",
                GetMapping = "GET endpoint", PostMapping = "POST endpoint", PutMapping = "PUT endpoint",
                PatchMapping = "PATCH endpoint", DeleteMapping = "DELETE endpoint", RequestMapping = "endpoint",
                ExceptionHandler = "exception handler",
                Scheduled = "scheduled",
                EventListener = "event listener", TransactionalEventListener = "event listener",
                KafkaListener = "message listener", JmsListener = "message listener",
                RabbitListener = "message listener", SqsListener = "message listener",
                Bean = "Spring bean",
                PostConstruct = "runs on startup", PreDestroy = "runs on shutdown",
                Test = "test", ParameterizedTest = "test", RepeatedTest = "test", TestFactory = "test",
                BeforeEach = "test setup", BeforeAll = "test setup",
                AfterEach = "test teardown", AfterAll = "test teardown",
            }

            -- What the framework uses the symbol on `line` (0-based) for, from the
            -- annotations on it and the lines directly above it
            local function entry_point(bufnr, line)
                local ft = vim.bo[bufnr].filetype
                if ft ~= "java" and ft ~= "kotlin" then return nil end
                local lines = vim.api.nvim_buf_get_lines(bufnr, math.max(0, line - 15), line + 1, false)
                for i = #lines, 1, -1 do
                    local l = lines[i]
                    for name in l:gmatch("@([%w_]+)") do
                        if entry_points[name] then return entry_points[name] end
                    end
                    -- stop at the end of the previous member/statement
                    if i < #lines and l:match("[;{}]%s*$") then break end
                end
            end

            -- text_format doesn't get the buffer, so these are added here
            local utils = require("symbol-usage.utils")
            local orig_extmark_opts = utils.make_extmark_opts
            utils.make_extmark_opts = function(text, opts, line, bufnr, id)
                if type(text) == "table" and text[1] and text[1][1] == "no usages" then
                    local kind = entry_point(bufnr, line)
                    if kind then
                        -- resolvers: where the schema defines them (<leader>gq jumps there)
                        local def = kind:match("^GraphQL") and require("graphql_schema").resolve(bufnr, line)
                        text = vim.deepcopy(text)
                        text[1][1] = def and ("%s · %s"):format(kind, vim.fs.basename(def.file)) or kind
                    end
                end
                local problems = type(text) == "table" and related_problems(bufnr, line) or 0
                if problems > 0 then
                    text = vim.list_extend(vim.deepcopy(text), {
                        { #text > 0 and " · " or "", "SymbolUsageContent" },
                        { ("%d related problem%s"):format(problems, problems == 1 and "" or "s"), "SymbolUsageContent" },
                    })
                end
                return orig_extmark_opts(text, opts, line, bufnr, id)
            end

            local kind = vim.lsp.protocol.SymbolKind
            require("symbol-usage").setup({
                text_format = text_format,
                vt_position = "above", -- own line above the symbol, at its indentation
                hl = { link = "SymbolUsageContent" }, -- the "loading..." placeholder
                kinds = { kind.Function, kind.Method, kind.Class, kind.Interface },
                implementation = { enabled = true },
                symbol_filter = function(ctx)
                    local uri, line = ctx.params.textDocument.uri, ctx.params.position.line
                    if ctx.method == "textDocument/references" then
                        local locs = {}
                        references[uri .. ":" .. line] = locs
                        return function(loc)
                            table.insert(locs, loc)
                            return true
                        end
                    elseif ctx.method == "textDocument/implementation" then
                        -- some servers (lua_ls, vtsls) return a plain function as its own
                        -- implementation; drop the symbol itself so only real ones count
                        return function(loc)
                            local loc_uri = loc.uri or loc.targetUri
                            local range = loc.range or loc.targetRange
                            return not (loc_uri == uri and range.start.line <= line and line <= range["end"].line)
                        end
                    end
                    return function() return true end
                end,
            })
        end,
    },
}
