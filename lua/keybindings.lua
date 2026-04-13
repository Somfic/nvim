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

-- qq and q: both quit the current window
maps("n", {
  { "qq", "<cmd>q<cr>", "Quit window" },
  { "q:", "<cmd>q<cr>", "Quit window (typo-friendly)" },
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
