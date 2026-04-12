-- Press `q` or `<Esc>` to close popup/scratch buffers (help, quickfix, lsp hover, etc.)
-- and to quit nvim entirely when launched on the empty [No Name] start buffer.

local group = vim.api.nvim_create_augroup("QuitWithQ", { clear = true })

local function bind_close(buf)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local function bind_quit(buf)
    vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = buf, silent = true, desc = "Quit nvim" })
    vim.keymap.set("n", "<Esc>", "<cmd>qa<cr>", { buffer = buf, silent = true, desc = "Quit nvim" })
end

-- Popup / non-file buffers: q or <Esc> closes the window.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = {
        "help",
        "qf",
        "lspinfo",
        "man",
        "checkhealth",
        "notify",
        "git",
        "fugitive",
        "neotest-output",
        "neotest-summary",
        "neotest-output-panel",
        "trouble",
        "noice",
    },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        bind_close(ev.buf)
    end,
})

-- Catch-all for any non-file scratch buffer (buftype is set).
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
        local bt = vim.bo[ev.buf].buftype
        if bt == "nofile" or bt == "quickfix" or bt == "help" then
            bind_close(ev.buf)
        end
    end,
})

-- Initial empty [No Name] buffer when nvim is launched with no args:
-- pressing q or <Esc> quits nvim entirely. Also propagates to the first oil
-- float if it auto-opens on launch.
local launched_empty = false

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
        if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and vim.bo.filetype == "" then
            launched_empty = true
            bind_quit(0)
        end
    end,
})

-- Oil buffers: q/<Esc> closes the float. If this is the launch-time oil float,
-- q/<Esc> quits nvim entirely instead (one-shot).
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "oil",
    callback = function(ev)
        if launched_empty then
            launched_empty = false
            bind_quit(ev.buf)
        else
            bind_close(ev.buf)
        end
    end,
})
