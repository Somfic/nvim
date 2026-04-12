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
            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in buffer" })
            vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Document symbols" })
            vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
            vim.keymap.set("n", "<leader>fS", function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                for _, client in ipairs(clients) do
                    if client.supports_method("workspace/symbol") then
                        builtin.lsp_dynamic_workspace_symbols()
                        return
                    end
                end
                vim.notify("No LSP workspace/symbol support — falling back to live grep", vim.log.levels.INFO)
                builtin.live_grep()
            end, { desc = "Workspace symbols (LSP, fallback live grep)" })
        end,
    },
}
