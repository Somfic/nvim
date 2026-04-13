return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        keys = {
            { "<leader>bc", function()
                local dap = require("dap")
                if dap.session() then
                    dap.terminate()
                    vim.schedule(function() require("dapui").close() end)
                else
                    dap.continue()
                end
            end, desc = "Start / Stop debug" },
            { "<F5>", function()
                local dap = require("dap")
                if dap.session() then
                    dap.terminate()
                    vim.schedule(function() require("dapui").close() end)
                else
                    dap.continue()
                end
            end, desc = "Start / Stop debug" },
            { "<leader>bb", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
            { "<F9>",       function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
            { "<leader>bB", function()
                vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
                    if cond then require("dap").set_breakpoint(cond) end
                end)
            end, desc = "Conditional breakpoint" },
            { "<leader>bi", function() require("dap").step_into() end, desc = "Step into" },
            { "<F11>",      function() require("dap").step_into() end, desc = "Step into" },
            { "<leader>bo", function() require("dap").step_over() end, desc = "Step over" },
            { "<F10>",      function() require("dap").step_over() end, desc = "Step over" },
            { "<leader>bO", function() require("dap").step_out() end,  desc = "Step out" },
            { "<leader>br", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>bl", function() require("dap").run_last() end,    desc = "Run last" },
            { "<leader>bq", function() require("dap").terminate() end,   desc = "Terminate" },
            { "<leader>bu", function() require("dapui").toggle() end,    desc = "Toggle DAP UI" },
            { "<leader>be", function() require("dapui").eval() end,      desc = "Evaluate expression",         mode = { "n", "v" } },
            { "<leader>bh", function() require("dap.ui.widgets").hover() end, desc = "Hover value (debug)" },
            { "<leader>bw", function()
                local expr
                local mode = vim.api.nvim_get_mode().mode
                if mode == "v" or mode == "V" or mode == "\22" then
                    vim.cmd('normal! "vy')
                    expr = vim.fn.getreg("v")
                else
                    expr = vim.fn.expand("<cexpr>")
                end
                -- Ensure dapui is initialized (safe even without an active session)
                local ok, dapui = pcall(require, "dapui")
                if not ok then return end
                if expr and expr ~= "" then
                    dapui.elements.watches.add(expr)
                    vim.notify("Watching: " .. expr, vim.log.levels.INFO)
                end
            end, desc = "Add watch", mode = { "n", "v", "i" } },
            { "<leader>bv", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.scopes, {
                    border = "rounded",
                    width = math.floor(vim.o.columns * 0.8),
                    height = math.floor(vim.o.lines * 0.8),
                })
            end, desc = "Browse variables tree" },
            { "<leader>bV", function() require("lsp.dap_variables").pick() end, desc = "Search variables (Telescope)" },
            { "<leader>bf", function()
                local widgets = require("dap.ui.widgets")
                widgets.centered_float(widgets.frames)
            end, desc = "Browse call stack" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = "scopes",      size = 0.35 },
                            { id = "breakpoints", size = 0.15 },
                            { id = "stacks",      size = 0.25 },
                            { id = "watches",     size = 0.25 },
                        },
                        size = 50,
                        position = "left",
                    },
                    {
                        elements = {
                            { id = "repl",    size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        size = 0.25,
                        position = "bottom",
                    },
                },
                floating = { border = "rounded" },
            })

            require("nvim-dap-virtual-text").setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = true,
                all_references = true,
                virt_text_pos = "eol",
                virt_text_win_col = nil,
            })

            dap.listeners.after.event_initialized.dapui_config = function() dapui.open() end

            -- Debug mode: buffer-local single-char keys while stopped at a breakpoint
            local debug_mapped_bufs = {}
            local debug_keys = {
                c = { function() dap.continue() end,          "Continue" },
                s = { function() dap.step_over() end,         "Next statement" },
                i = { function() dap.step_into() end,         "Step into" },
                o = { function() dap.step_out() end,          "Step out" },
                b = { function() dap.toggle_breakpoint() end, "Toggle breakpoint" },
                r = { function() dap.run_to_cursor() end,     "Run to cursor" },
                q = { function() dap.terminate() end,         "Terminate" },
                K = { function() require("dap.ui.widgets").hover() end, "Hover value" },
            }
            -- Neutralise edit-entry keys so holding/pressing them can't mutate the buffer
            local blocked_keys = { "I", "a", "A", "O", "p", "P", "x", "X", "d", "C", "S", "D", "R", "~" }

            -- Cheatsheet rendered as a virt_lines extmark at the bottom of the stopped buffer
            local cheatsheet_ns = vim.api.nvim_create_namespace("dap_cheatsheet")
            local cheatsheet_extmarks = {}
            local function show_cheatsheet(bufnr)
                if cheatsheet_extmarks[bufnr] then return end
                local ordered = { "c", "s", "i", "o", "b", "r", "K", "q" }
                local parts = {}
                for _, k in ipairs(ordered) do
                    table.insert(parts, { { " " .. k .. " ", "DiagnosticError" }, { " " .. debug_keys[k][2] .. "  ", "Comment" } })
                end
                local line = { { "  DEBUG  ", "DiagnosticError" } }
                for _, p in ipairs(parts) do
                    for _, seg in ipairs(p) do table.insert(line, seg) end
                end
                local last = vim.api.nvim_buf_line_count(bufnr) - 1
                local id = vim.api.nvim_buf_set_extmark(bufnr, cheatsheet_ns, last, 0, {
                    virt_lines = { line },
                    virt_lines_above = false,
                })
                cheatsheet_extmarks[bufnr] = id
            end
            local function hide_cheatsheet()
                for bufnr, id in pairs(cheatsheet_extmarks) do
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        pcall(vim.api.nvim_buf_del_extmark, bufnr, cheatsheet_ns, id)
                    end
                end
                cheatsheet_extmarks = {}
            end

            local prev_modifiable = {}
            local function enter_debug_mode(bufnr)
                if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return end
                if debug_mapped_bufs[bufnr] then return end
                debug_mapped_bufs[bufnr] = {}
                for lhs, spec in pairs(debug_keys) do
                    vim.keymap.set("n", lhs, spec[1], { buffer = bufnr, desc = "[DEBUG] " .. spec[2] })
                    debug_mapped_bufs[bufnr][lhs] = true
                end
                for _, lhs in ipairs(blocked_keys) do
                    vim.keymap.set("n", lhs, "<nop>", { buffer = bufnr, desc = "[DEBUG] blocked" })
                    debug_mapped_bufs[bufnr][lhs] = true
                end
                prev_modifiable[bufnr] = vim.bo[bufnr].modifiable
                vim.bo[bufnr].modifiable = false
                vim.b[bufnr].debug_mode = true
                show_cheatsheet(bufnr)
                vim.cmd("redrawstatus")
            end

            local function exit_debug_mode()
                for bufnr, keys in pairs(debug_mapped_bufs) do
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        for lhs in pairs(keys) do
                            pcall(vim.keymap.del, "n", lhs, { buffer = bufnr })
                        end
                        if prev_modifiable[bufnr] ~= nil then
                            vim.bo[bufnr].modifiable = prev_modifiable[bufnr]
                        end
                        vim.b[bufnr].debug_mode = false
                    end
                end
                debug_mapped_bufs = {}
                prev_modifiable = {}
                vim.g.dap_stopped = false
                pcall(vim.api.nvim_clear_autocmds, { group = debug_mode_aug })
                hide_cheatsheet()
                vim.cmd("redrawstatus")
            end

            -- Enforce debug mode on any normal file buffer the user enters while stopped
            local debug_mode_aug = vim.api.nvim_create_augroup("DapDebugMode", { clear = true })
            local function is_source_buf(bufnr)
                if not vim.api.nvim_buf_is_valid(bufnr) then return false end
                local bt = vim.bo[bufnr].buftype
                local ft = vim.bo[bufnr].filetype
                local name = vim.api.nvim_buf_get_name(bufnr)
                if bt ~= "" then return false end
                if ft:match("^dap") or name:find("%[dap") or name == "" then return false end
                return true
            end

            dap.listeners.after.event_stopped.debug_mode = function()
                vim.g.dap_stopped = true
                -- Lock every currently visible source buffer immediately
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if is_source_buf(buf) then enter_debug_mode(buf) end
                end
                -- Also lock any buffer the user navigates to while stopped
                vim.api.nvim_create_autocmd("BufEnter", {
                    group = debug_mode_aug,
                    callback = function(args)
                        if not vim.g.dap_stopped then return end
                        if is_source_buf(args.buf) then enter_debug_mode(args.buf) end
                    end,
                })
                vim.schedule(function() vim.cmd("redrawstatus") end)
            end
            dap.listeners.after.event_continued.debug_mode = exit_debug_mode
            dap.listeners.before.event_terminated.debug_mode = exit_debug_mode
            dap.listeners.before.event_exited.debug_mode = exit_debug_mode

            -- If closing a window would leave only dapui panels, close them too.
            local function is_dap_buf(bufnr)
                local ft = vim.bo[bufnr].filetype or ""
                local name = vim.api.nvim_buf_get_name(bufnr)
                return ft:match("^dap") ~= nil
                    or name:find("%[dap") ~= nil
                    or name:find("%[DAP") ~= nil
            end
            vim.api.nvim_create_autocmd("WinClosed", {
                callback = function(args)
                    local closing_win = tonumber(args.match)
                    vim.schedule(function()
                        local remaining = vim.tbl_filter(function(w)
                            return w ~= closing_win and vim.api.nvim_win_is_valid(w)
                                and vim.api.nvim_win_get_config(w).relative == ""
                        end, vim.api.nvim_list_wins())
                        if #remaining == 0 then return end
                        for _, w in ipairs(remaining) do
                            if not is_dap_buf(vim.api.nvim_win_get_buf(w)) then return end
                        end
                        dapui.close()
                        vim.schedule(function()
                            local wins = vim.tbl_filter(function(w)
                                return vim.api.nvim_win_get_config(w).relative == ""
                            end, vim.api.nvim_list_wins())
                            local only_dap = #wins > 0
                            for _, w in ipairs(wins) do
                                if not is_dap_buf(vim.api.nvim_win_get_buf(w)) then
                                    only_dap = false
                                    break
                                end
                            end
                            if only_dap or #wins == 0 then
                                vim.cmd("silent! qa!")
                            end
                        end)
                    end)
                end,
            })
            -- Intentionally not auto-closing on event_terminated/event_exited:
            -- short programs exit immediately after a breakpoint and would yank
            -- the UI before you can inspect anything. Close manually with <leader>bu.

            -- codelldb adapter for Rust / C / C++
            local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = mason_bin .. "/codelldb",
                    args = { "--port", "${port}" },
                },
            }

            -- Build the cargo binary, return the path to the first produced executable
            local function cargo_build_and_find_binary()
                vim.notify("cargo build...", vim.log.levels.INFO)
                local out = vim.fn.systemlist({ "cargo", "build", "--message-format=json" })
                if vim.v.shell_error ~= 0 then
                    vim.notify("cargo build failed", vim.log.levels.ERROR)
                    return nil
                end
                for _, line in ipairs(out) do
                    local ok, msg = pcall(vim.json.decode, line)
                    if ok and msg.reason == "compiler-artifact" and msg.executable and msg.target
                        and vim.tbl_contains(msg.target.kind or {}, "bin") then
                        return msg.executable
                    end
                end
                vim.notify("cargo build produced no binary", vim.log.levels.ERROR)
                return nil
            end

            dap.configurations.rust = {
                {
                    name = "Launch (cargo build + run)",
                    type = "codelldb",
                    request = "launch",
                    program = cargo_build_and_find_binary,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                    sourceLanguages = { "rust" },
                    initCommands = { "settings set target.source-map . ${workspaceFolder}" },
                },
            }
            local c_cfg = {
                {
                    name = "Launch (cargo build + run)",
                    type = "codelldb",
                    request = "launch",
                    program = cargo_build_and_find_binary,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }
            dap.configurations.c = c_cfg
            dap.configurations.cpp = c_cfg

            vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn",  linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DiagnosticInfo",  linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",    linehl = "Visual", numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected",  { text = "●", texthl = "DiagnosticHint",  linehl = "", numhl = "" })
        end,
    },
}
