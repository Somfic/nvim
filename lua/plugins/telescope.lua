return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = "> ",
                    selection_caret = "> ",
                    entry_prefix = "  ",
                    path_display = { "smart" },
                    dynamic_preview_title = true,
                    layout_config = {
                        prompt_position = "top",
                    },
                    sorting_strategy = "ascending",
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                    },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<Tab>"] = actions.move_selection_next,
                            ["<S-Tab>"] = actions.move_selection_previous,
                            ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<C-c>"] = actions.close,
                        },
                        n = {
                            ["j"] = actions.move_selection_next,
                            ["k"] = actions.move_selection_previous,
                            ["h"] = actions.select_horizontal,
                            ["l"] = actions.select_default,
                            ["q"] = actions.close,
                            ["<Esc>"] = actions.close,
                        },
                    },
                },
                extensions = {
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown({}),
                    },
                },
            })

            telescope.load_extension("ui-select")

            -- keymaps
            local builtin = require("telescope.builtin")

            -- If we trigger a picker from inside a floating window (e.g. the launch
            -- oil float), close that float first so the selected file opens in a
            -- normal full-size window instead of replacing the float's contents.
            local function from_normal_window(picker)
                return function()
                    if vim.api.nvim_win_get_config(0).relative ~= "" then
                        pcall(vim.api.nvim_win_close, 0, false)
                    end
                    picker()
                end
            end

            vim.keymap.set("n", "<leader>ff", from_normal_window(builtin.find_files), { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", from_normal_window(builtin.live_grep), { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", from_normal_window(builtin.buffers), { desc = "Find buffers" })
            vim.keymap.set(
                "n",
                "<leader>fh",
                from_normal_window(builtin.current_buffer_fuzzy_find),
                { desc = "Fuzzy find in buffer" }
            )
            vim.keymap.set(
                "n",
                "<leader>fs",
                from_normal_window(builtin.lsp_document_symbols),
                { desc = "Document symbols" }
            )
            vim.keymap.set(
                "n",
                "<leader>fw",
                from_normal_window(builtin.grep_string),
                { desc = "Grep word under cursor" }
            )
            vim.keymap.set(
                "n",
                "<leader>fu",
                from_normal_window(builtin.lsp_references),
                { desc = "Find usages (references)" }
            )
            vim.keymap.set("n", "<leader>fS", from_normal_window(function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                for _, client in ipairs(clients) do
                    if client.supports_method("workspace/symbol") then
                        builtin.lsp_dynamic_workspace_symbols()
                        return
                    end
                end
                vim.notify("No LSP workspace/symbol support — falling back to live grep", vim.log.levels.INFO)
                builtin.live_grep()
            end), { desc = "Workspace symbols (LSP, fallback live grep)" })
        end,
    },
}
