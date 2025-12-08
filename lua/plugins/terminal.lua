return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        config = function()
            local Terminal = require("toggleterm.terminal").Terminal

            require("toggleterm").setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                shade_terminals = true,
                shading_factor = 2,
                start_in_insert = true,
                insert_mappings = true,
                terminal_mappings = true,
                persist_size = true,
                persist_mode = true,
                direction = "float",
                close_on_exit = true,
                shell = vim.o.shell,
                float_opts = {
                    border = "curved",
                    winblend = 0,
                },
            })

            -- Store named terminals
            _G.named_terminals = _G.named_terminals or {}

            -- Create a new named terminal
            local function create_named_terminal()
                local name = vim.fn.input("Terminal name: ")
                if name and name ~= "" then
                    local term = Terminal:new({
                        display_name = name,
                        direction = "float",
                        on_open = function(term)
                            vim.cmd("startinsert!")
                        end,
                    })
                    _G.named_terminals[name] = term
                    term:toggle()
                end
            end

            -- Select and open a named terminal with Telescope
            local function select_terminal()
                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                local previewers = require("telescope.previewers")

                local terminals = {}
                for name, _ in pairs(_G.named_terminals) do
                    table.insert(terminals, name)
                end

                if #terminals == 0 then
                    vim.notify("No named terminals. Create one with <leader>tn", vim.log.levels.INFO)
                    return
                end

                pickers.new({}, {
                    prompt_title = "Terminals",
                    finder = finders.new_table({
                        results = terminals,
                    }),
                    sorter = conf.generic_sorter({}),
                    previewer = previewers.new_buffer_previewer({
                        title = "Terminal Preview",
                        define_preview = function(self, entry)
                            local term = _G.named_terminals[entry[1]]
                            if term and term.bufnr and vim.api.nvim_buf_is_valid(term.bufnr) then
                                local lines = vim.api.nvim_buf_get_lines(term.bufnr, 0, -1, false)
                                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                            else
                                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "[Terminal not initialized]" })
                            end
                        end,
                    }),
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            actions.close(prompt_bufnr)
                            local selection = action_state.get_selected_entry()
                            if selection then
                                _G.named_terminals[selection[1]]:toggle()
                            end
                        end)
                        return true
                    end,
                }):find()
            end

            -- Keymaps
            vim.keymap.set("n", "<leader>tn", create_named_terminal, { desc = "New named terminal" })
            vim.keymap.set("n", "<leader>ft", select_terminal, { desc = "Find terminal" })
            vim.keymap.set("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Terminal horizontal" })
            vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal vertical" })

            -- Terminal mode keymaps
            function _G.set_terminal_keymaps()
                local opts = { buffer = 0 }
                -- Esc closes floating terminals, normal mode for others
                vim.keymap.set("t", "<esc>", function()
                    local win = vim.api.nvim_get_current_win()
                    local config = vim.api.nvim_win_get_config(win)
                    if config.relative ~= "" then
                        -- Floating window - close it
                        vim.cmd("close")
                    else
                        -- Normal split - go to normal mode
                        vim.cmd([[normal! \<C-\>\<C-n>]])
                    end
                end, opts)
                vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
                vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
                vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
                vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
            end

            vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
        end,
    },
}
