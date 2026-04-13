return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        keys = {
            { "<leader>bc", function() require("dap").continue() end,          desc = "Continue / Start" },
            { "<F5>",       function() require("dap").continue() end,          desc = "Continue / Start" },
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
                commented = true,
                virt_text_pos = "eol",
            })

            dap.listeners.before.attach.dapui_config = function() dapui.open() end
            dap.listeners.before.launch.dapui_config = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
            dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

            vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn",  linehl = "", numhl = "" })
            vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DiagnosticInfo",  linehl = "", numhl = "" })
            vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk",    linehl = "Visual", numhl = "" })
            vim.fn.sign_define("DapBreakpointRejected",  { text = "●", texthl = "DiagnosticHint",  linehl = "", numhl = "" })
        end,
    },
}
