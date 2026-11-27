vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

local function maps(mode, mappings)
  for _, mapping in ipairs(mappings) do
    map(mode, mapping[1], mapping[2], mapping[3])
  end
end

-- unbind arrow keys
maps("n", {
  { "<up>",    "<nop>", "Unbind Up Arrow" },
  { "<down>",  "<nop>", "Unbind Down Arrow" },
  { "<left>",  "<nop>", "Unbind Left Arrow" },
  { "<right>", "<nop>", "Unbind Right Arrow" },
})

-- disable the search history windows (q/, q?)
maps("n", {
  { "q/", "<nop>", "Disable search history window" },
  { "q?", "<nop>", "Disable backward search history window" },
})

-- q: quits the current window (typo-friendly)
maps("n", {
  { "q:", "<cmd>q<cr>", "Quit window (typo-friendly)" },
})

-- qq closes every non-file window in this tab (references/Trouble, quickfix, help,
-- file tree, terminals, ...) and keeps the file splits. Macros: record into another
-- register (qw, qe, ...) since qq is taken.
map("n", "qq", function()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local files = 0
  for _, win in ipairs(wins) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then files = files + 1 end
  end
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    -- never close the last window
    if vim.bo[buf].buftype ~= "" and (files > 0 or #vim.api.nvim_tabpage_list_wins(0) > 1) then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
end, "Close non-file windows")

-- top/bottom of file ([[ ]] instead of gg/G, which frees gg up for lazygit)
maps({ "n", "x", "o" }, {
  { "[[", "gg", "Top of file" },
  { "]]", "G",  "Bottom of file" },
})

-- several runtime ftplugins (sql, markdown, rust, go, python, ...) map their own
-- buffer-local [[ ]] section jumps, which would shadow the ones above
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TopBottomKeys", { clear = true }),
  callback = function(ev)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(ev.buf) then return end
      for _, mode in ipairs({ "n", "x", "o" }) do
        pcall(vim.keymap.del, mode, "[[", { buffer = ev.buf })
        pcall(vim.keymap.del, mode, "]]", { buffer = ev.buf })
      end
    end)
  end,
})

-- jump list
maps("n", {
  { "gb", "<C-o>", "Go back to previous position" },
  { "gf", "<C-i>", "Go forward in jump list" },
})

-- buffer navigation
maps("n", {
  { "<Tab>",   "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
  { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer" },
  { "d<Tab>",  "<cmd>bd<cr>",                  "Delete buffer" },
})

-- window/pane navigation
maps("n", {
  { "<C-h>", "<C-w>h", "Window left" },
  { "<C-j>", "<C-w>j", "Window down" },
  { "<C-k>", "<C-w>k", "Window up" },
  { "<C-l>", "<C-w>l", "Window right" },
})

-- move lines up/down
maps("n", {
  { "<A-j>", "<cmd>m .+1<cr>==", "Move line down" },
  { "<A-k>", "<cmd>m .-2<cr>==", "Move line up" },
})
maps("v", {
  { "<A-j>", ":m '>+1<cr>gv=gv", "Move selection down" },
  { "<A-k>", ":m '<-2<cr>gv=gv", "Move selection up" },
})
