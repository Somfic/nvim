vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

local function maps(mode, mappings)
    for _, mapping in ipairs(mappings) do
        map(mode, mapping[1], mapping[2], mapping[3])
    end
end

local function group(prefix, group_name, mappings)
    -- register the group with which-key
    if pcall(require, "which-key") then
        require("which-key").add({
            { prefix, group = group_name }
        })
    end

    -- set all the keymaps in the group
    for _, mapping in ipairs(mappings) do
        map("n", prefix .. mapping[1], mapping[2], mapping[3])
    end
end

-- unbind arrow keys
maps("n", {
    { "<up>",    "<nop>", "Unbind Up Arrow" },
    { "<down>",  "<nop>", "Unbind Down Arrow" },
    { "<left>",  "<nop>", "Unbind Left Arrow" },
    { "<right>", "<nop>", "Unbind Right Arrow" },
})

-- jump list
maps("n", {
    { "gb", "<C-o>", "Go back to previous position" },
    { "gf", "<C-i>", "Go forward in jump list" },
})

-- buffer navigation
maps("n", {
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", "Previous buffer" },
    { "d<Tab>", "<cmd>bd<cr>", "Delete buffer" },
})

-- buffer management
group("<leader>b", "Buffer", {
    { "n", "<cmd>Telescope find_files<cr>", "New buffer" },
    { "b", "<cmd>Telescope buffers<cr>", "Find buffer" },
})
