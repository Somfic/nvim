return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            -- Filename left, directory right-aligned to the results window edge
            local function right_aligned_path(_, path)
                local name = vim.fs.basename(path)
                local dir = vim.fs.dirname(path)
                if dir == "." or dir == "" then return name end

                local results_width
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "TelescopeResults" then
                        results_width = vim.api.nvim_win_get_width(win)
                        break
                    end
                end
                results_width = (results_width or math.floor(vim.o.columns * 0.5)) - 4

                local name_w = vim.fn.strdisplaywidth(name)
                local dir_w = vim.fn.strdisplaywidth(dir)
                local pad = math.max(2, results_width - name_w - dir_w)
                local display = name .. string.rep(" ", pad) .. dir
                return display, { { { name_w + pad, name_w + pad + dir_w }, "Comment" } }
            end

            telescope.setup({
                defaults = {
                    prompt_prefix = "> ",
                    selection_caret = "> ",
                    entry_prefix = "  ",
                    path_display = right_aligned_path,
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
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                },
            })

            telescope.load_extension("ui-select")
            telescope.load_extension("fzf")

            -- keymaps
            local builtin = require("telescope.builtin")

            -- Entry maker that makes fuzzy matching ignore directory, matching only on filename
            local default_file_entry = require("telescope.make_entry").gen_from_file({})
            local function filename_only_entry_maker(line)
                local entry = default_file_entry(line)
                if entry then
                    entry.ordinal = vim.fs.basename(entry.value)
                end
                return entry
            end

            local function find_files()
                builtin.find_files({ entry_maker = filename_only_entry_maker })
            end

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

            vim.keymap.set("n", "<leader>ff", from_normal_window(find_files), { desc = "Find files" })
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
            vim.keymap.set("n", "<leader>fS", from_normal_window(function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                for _, client in ipairs(clients) do
                    if client:supports_method("workspace/symbol") then
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
