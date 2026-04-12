-- Press `q` to close popup/scratch buffers (help, quickfix, lsp hover, etc.)
-- and to quit nvim entirely when launched on the empty [No Name] start buffer.

local group = vim.api.nvim_create_augroup("QuitWithQ", { clear = true })

-- Popup / non-file buffers: q closes the window.
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
        "TelescopePrompt",
        "noice",
    },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
    end,
})

-- Catch-all for any non-file scratch buffer (buftype is set).
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function(ev)
        local bt = vim.bo[ev.buf].buftype
        if bt == "nofile" or bt == "quickfix" or bt == "help" then
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
        end
    end,
})

-- Initial empty [No Name] buffer when nvim is launched with no args:
-- pressing q quits nvim entirely. Also propagates to the first oil float
-- if it auto-opens on launch.
local launched_empty = false

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
        if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" and vim.bo.filetype == "" then
            launched_empty = true
            vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = 0, silent = true, desc = "Quit nvim" })
        end
    end,
})

-- Oil buffers: q closes the float. If this is the launch-time oil float,
-- q quits nvim entirely instead (one-shot).
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "oil",
    callback = function(ev)
        if launched_empty then
            launched_empty = false
            vim.keymap.set("n", "q", "<cmd>qa<cr>", { buffer = ev.buf, silent = true, desc = "Quit nvim" })
        else
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
        end
    end,
})
