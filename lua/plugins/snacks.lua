-- snacks.nvim: picker, notifications, vim.ui.input/select, indent guides, smooth scroll,
-- lazygit, terminals

-- If a picker is opened from a floating window (e.g. the launch oil float), close the
-- float first so the chosen file opens in a normal window instead of inside the float.
-- `source` is a picker name or a function.
local function pick(source, opts)
    return function()
        if vim.api.nvim_win_get_config(0).relative ~= "" then
            pcall(vim.api.nvim_win_close, 0, false)
        end
        if type(source) == "function" then
            source()
        else
            Snacks.picker[source](opts)
        end
    end
end

-- Find files, fuzzy matching on the file name only (the directory is still shown)
local function find_files()
    Snacks.picker.files({
        transform = function(item)
            item.text = vim.fs.basename(item.file)
        end,
    })
end

local function workspace_symbols()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client:supports_method("workspace/symbol") then
            return Snacks.picker.lsp_workspace_symbols()
        end
    end
    vim.notify("No LSP workspace/symbol support — falling back to live grep", vim.log.levels.INFO)
    Snacks.picker.grep()
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        { "<leader>ff", pick(find_files),          desc = "Find files" },
        { "<leader>fg", pick("grep"),              desc = "Live grep" },
        { "<leader>fb", pick("buffers"),           desc = "Find buffers" },
        { "<leader>fh", pick("lines"),             desc = "Fuzzy find in buffer" },
        { "<leader>fs", pick("lsp_symbols"),       desc = "Document symbols" },
        { "<leader>fw", pick("grep_word"),         desc = "Grep word under cursor", mode = { "n", "x" } },
        { "<leader>fS", pick(workspace_symbols),   desc = "Workspace symbols (LSP, fallback live grep)" },
        { "<leader>fr", pick("recent"),            desc = "Recent files" },
        { "<leader>f.", pick("resume"),            desc = "Resume last picker" },
        { "<leader>c",  function() Snacks.lazygit() end, desc = "LazyGit" },
        { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification history" },
    },
    opts = {
        bigfile = { enabled = true },
        picker = {
            enabled = true,
            ui_select = true, -- code actions etc.
            formatters = {
                file = { filename_first = true }, -- name first, directory dimmed after it
            },
            win = {
                input = {
                    keys = {
                        ["<Tab>"] = { "list_down", mode = { "i", "n" } },
                        ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
                        ["<C-c>"] = { "cancel", mode = { "i", "n" } },
                        ["q"] = "cancel",
                        ["l"] = "confirm",
                        ["h"] = "edit_split",
                    },
                },
                list = {
                    keys = {
                        ["<Tab>"] = "list_down",
                        ["<S-Tab>"] = "list_up",
                        ["l"] = "confirm",
                        ["h"] = "edit_split",
                    },
                },
            },
        },
        notifier = {
            enabled = true,
            timeout = 3000,
            style = "compact",
            top_down = true,
        },
        input = { enabled = true },
        indent = {
            enabled = true,
            indent = { enabled = false }, -- only the current scope, like mini.indentscope
            scope = { enabled = true, char = "│" },
            animate = { duration = { step = 10, total = 80 } },
            filter = function(buf)
                return vim.bo[buf].buftype == "" and vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false
            end,
        },
        scroll = {
            enabled = true,
            animate = { duration = { step = 15, total = 150 }, easing = "outQuad" },
        },
        lazygit = { enabled = true },
        terminal = { enabled = true },
        styles = {
            notification = { border = "rounded" },
            input = { border = "rounded" },
        },
    },
}
