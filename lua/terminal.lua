-- Terminals on top of Snacks.terminal (snacks.lua). A terminal is identified by its
-- cmd/cwd/env/count, so each layout and each named terminal gets its own count.
local FLOAT, HORIZONTAL, VERTICAL = 1, 2, 3
local first_named = 100

local named = {} -- name -> count
local next_count = first_named

local function float_win(title)
    return {
        position = "float",
        border = "rounded",
        title = title and (" " .. title .. " ") or nil,
        title_pos = "center",
        width = 0.85,
        height = 0.8,
    }
end

-- <Esc> hides a floating terminal; in a split it drops to normal mode
local function esc_key()
    return {
        "<esc>",
        function(self)
            if self:is_floating() then
                self:hide()
            else
                vim.cmd("stopinsert")
            end
        end,
        mode = "t",
        desc = "Hide float / normal mode",
    }
end

local function toggle(count, win)
    win.keys = { term_normal = esc_key() } -- replaces snacks' double-<esc>
    Snacks.terminal.toggle(nil, { count = count, win = win })
end

local function toggle_named(name)
    toggle(named[name], float_win(name))
end

local function create_named_terminal()
    vim.ui.input({ prompt = "Terminal name: " }, function(name)
        if not name or name == "" then return end
        if not named[name] then
            named[name] = next_count
            next_count = next_count + 1
        end
        toggle_named(name)
    end)
end

-- Pick a named terminal with Telescope, previewing its scrollback
local function select_terminal()
    local names = vim.tbl_keys(named)
    if #names == 0 then
        vim.notify("No named terminals. Create one with <leader>tn", vim.log.levels.INFO)
        return
    end
    table.sort(names)

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    pickers.new({}, {
        prompt_title = "Terminals",
        finder = finders.new_table({ results = names }),
        sorter = conf.generic_sorter({}),
        previewer = previewers.new_buffer_previewer({
            title = "Terminal Preview",
            define_preview = function(self, entry)
                local term = Snacks.terminal.get(nil, { count = named[entry[1]], create = false })
                local lines = { "[Terminal not running]" }
                if term and term.buf and vim.api.nvim_buf_is_valid(term.buf) then
                    lines = vim.api.nvim_buf_get_lines(term.buf, 0, -1, false)
                end
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            end,
        }),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then toggle_named(selection[1]) end
            end)
            return true
        end,
    }):find()
end

-- Window navigation out of any terminal (including lazygit)
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("TerminalKeymaps", { clear = true }),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", opts)
        vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", opts)
        vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", opts)
        vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", opts)
    end,
})

local function float_toggle() toggle(FLOAT, float_win()) end

vim.keymap.set({ "n", "i", "t" }, [[<C-\>]], float_toggle, { desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>tn", create_named_terminal, { desc = "New named terminal" })
vim.keymap.set("n", "<leader>tf", select_terminal, { desc = "Find terminal" })
vim.keymap.set("n", "<leader>th", function()
    toggle(HORIZONTAL, { position = "bottom", height = 15 })
end, { desc = "Terminal horizontal" })
vim.keymap.set("n", "<leader>tv", function()
    toggle(VERTICAL, { position = "right", width = 0.4 })
end, { desc = "Terminal vertical" })

