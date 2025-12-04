return {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
            default_file_explorer = true,

            -- Columns to show
            columns = {
                "icon",
                -- "permissions",
                -- "size",
                -- "mtime",
            },

            -- Buffer-local options for oil buffers
            buf_options = {
                buflisted = false,
                bufhidden = "hide",
            },

            -- Window-local options for oil buffers
            win_options = {
                wrap = false,
                signcolumn = "no",
                cursorcolumn = false,
                foldcolumn = "0",
                spell = false,
                list = false,
                conceallevel = 3,
                concealcursor = "nvic",
            },

            -- Delete files to trash instead of permanently
            delete_to_trash = true,

            -- Skip confirmation for simple operations
            skip_confirm_for_simple_edits = true,

            -- Prompt before certain destructive actions
            prompt_save_on_select_new_entry = true,

            -- Cleanup behavior
            cleanup_delay_ms = 2000,

            -- Keymaps in oil buffer
            keymaps = {
                ["g?"] = "actions.show_help",
                ["<CR>"] = "actions.select",
                ["<C-s>"] = "actions.select_vsplit",
                ["<C-h>"] = "actions.select_split",
                ["<C-t>"] = "actions.select_tab",
                ["<C-p>"] = "actions.preview",
                ["<C-c>"] = "actions.close",
                ["<C-r>"] = "actions.refresh",
                ["-"] = "actions.parent",
                ["_"] = "actions.open_cwd",
                ["`"] = "actions.cd",
                ["~"] = "actions.tcd",
                ["gs"] = "actions.change_sort",
                ["gx"] = "actions.open_external",
                ["g."] = "actions.toggle_hidden",
                ["g\\"] = "actions.toggle_trash",
            },

            -- Set to false to disable all keymaps
            use_default_keymaps = true,

            view_options = {
                -- Show hidden files by default
                show_hidden = true,

                -- This function defines what is considered a "hidden" file
                is_hidden_file = function(name, bufnr)
                    return vim.startswith(name, ".")
                end,

                -- This function defines what will never be shown
                is_always_hidden = function(name, bufnr)
                    return name == ".." or name == ".git"
                end,

                sort = {
                    -- sort order: "asc" or "desc"
                    { "type", "asc" },
                    { "name", "asc" },
                },
            },

            -- Configuration for floating window
            float = {
                padding = 2,
                max_width = 90,
                max_height = 30,
                border = "rounded",
                win_options = {
                    winblend = 0,
                },
            },
        })

        -- Keymaps for opening Oil
        vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open file explorer" })
        vim.keymap.set("n", "<leader>E", "<CMD>Oil --float<CR>", { desc = "Open file explorer (float)" })
    end,
}
