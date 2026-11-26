-- Entry maker that makes fuzzy matching ignore directory, matching only on filename
local function find_files()
    local default_file_entry = require("telescope.make_entry").gen_from_file({})
    require("telescope.builtin").find_files({
        entry_maker = function(line)
            local entry = default_file_entry(line)
            if entry then
                entry.ordinal = vim.fs.basename(entry.value)
            end
            return entry
        end,
    })
end

local function workspace_symbols()
    local builtin = require("telescope.builtin")
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client:supports_method("workspace/symbol") then
            builtin.lsp_dynamic_workspace_symbols()
            return
        end
    end
    vim.notify("No LSP workspace/symbol support — falling back to live grep", vim.log.levels.INFO)
    builtin.live_grep()
end

-- If we trigger a picker from inside a floating window (e.g. the launch oil float),
-- close that float first so the selected file opens in a normal full-size window
-- instead of replacing the float's contents. `fn` is a function or a builtin's name.
local function picker(fn)
    return function()
        if vim.api.nvim_win_get_config(0).relative ~= "" then
            pcall(vim.api.nvim_win_close, 0, false)
        end
        if type(fn) == "string" then
            require("telescope.builtin")[fn]()
        else
            fn()
        end
    end
end

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = {
            { "<leader>ff", picker(find_files),                 desc = "Find files" },
            { "<leader>fg", picker("live_grep"),                desc = "Live grep" },
            { "<leader>fb", picker("buffers"),                  desc = "Find buffers" },
            { "<leader>fh", picker("current_buffer_fuzzy_find"), desc = "Fuzzy find in buffer" },
            { "<leader>fs", picker("lsp_document_symbols"),     desc = "Document symbols" },
            { "<leader>fw", picker("grep_string"),              desc = "Grep word under cursor" },
            { "<leader>fS", picker(workspace_symbols),          desc = "Workspace symbols (LSP, fallback live grep)" },
        },
        init = function()
            -- load telescope (and its ui-select extension) on the first vim.ui.select
            local original = vim.ui.select
            local function shim(...)
                require("lazy").load({ plugins = { "telescope.nvim" } })
                if vim.ui.select == shim then
                    vim.ui.select = original -- extension didn't take over; don't recurse
                end
                return vim.ui.select(...)
            end
            vim.ui.select = shim
        end,
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
        end,
    },
}
