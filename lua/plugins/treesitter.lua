-- nvim-treesitter `main` branch: it only installs parsers and queries. Highlighting,
-- folds and indent are started per buffer here; textobjects are mapped explicitly.
local parsers = {
    "lua", "vim", "vimdoc", "query",
    "javascript", "typescript", "tsx", "json", "html", "css", "scss", "svelte",
    "rust", "python", "go", "c", "java", "bash", "toml", "yaml",
    "markdown", "markdown_inline", "regex",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- the main branch doesn't support lazy-loading
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")
            ts.install(parsers) -- async; already-installed parsers are skipped

            -- parsers nvim-treesitter knows about, for installing on first use
            local available = {}
            for _, lang in ipairs(ts.get_available()) do
                available[lang] = true
            end

            -- Incremental selection (removed from the main branch): <CR> selects the node
            -- under the cursor, <CR> again grows to the parent, <BS> shrinks back.
            local history = {} -- buf -> stack of selected nodes

            local function select_node(node)
                local sr, sc, er, ec = node:range()
                -- an end column of 0 means the node ends at the end of the previous line
                if ec == 0 and er > sr then
                    er = er - 1
                    ec = #vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1]
                end
                -- leave visual mode, then select charwise from start to end
                if vim.api.nvim_get_mode().mode:match("^[vV\22]") then
                    vim.cmd("normal! \27")
                end
                vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
                vim.cmd("normal! v")
                vim.api.nvim_win_set_cursor(0, { er + 1, math.max(ec - 1, 0) })
            end

            local function init_selection()
                local node = vim.treesitter.get_node()
                if not node then return end
                history[vim.api.nvim_get_current_buf()] = { node }
                select_node(node)
            end

            local function node_incremental()
                local buf = vim.api.nvim_get_current_buf()
                local stack = history[buf]
                if not stack or #stack == 0 then return init_selection() end
                local node = stack[#stack]
                local range = { node:range() }
                -- skip parents that cover exactly the same text
                local parent = node:parent()
                while parent and vim.deep_equal({ parent:range() }, range) do
                    parent = parent:parent()
                end
                if not parent then return end
                table.insert(stack, parent)
                select_node(parent)
            end

            local function node_decremental()
                local stack = history[vim.api.nvim_get_current_buf()]
                if not stack or #stack < 2 then return end
                table.remove(stack)
                select_node(stack[#stack])
            end

            local function start(buf, lang)
                if not pcall(vim.treesitter.start, buf, lang) then return end
                -- only where the parser ships indent queries
                if vim.treesitter.query.get(lang, "indents") then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
                vim.keymap.set("n", "<CR>", init_selection, { buffer = buf, desc = "Start node selection" })
                vim.keymap.set("x", "<CR>", node_incremental, { buffer = buf, desc = "Grow node selection" })
                vim.keymap.set("x", "<BS>", node_decremental, { buffer = buf, desc = "Shrink node selection" })
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    if not lang then return end
                    if vim.treesitter.language.add(lang) then
                        start(ev.buf, lang)
                    elseif available[lang] then
                        -- auto_install: fetch the parser, then start once it's built
                        ts.install(lang):await(function()
                            if vim.api.nvim_buf_is_valid(ev.buf) then start(ev.buf, lang) end
                        end)
                    end
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = "VeryLazy",
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local objects = {
                af = { "@function.outer", "around function" },
                ["if"] = { "@function.inner", "inside function" },
                ac = { "@class.outer", "around class" },
                ic = { "@class.inner", "inside class" },
                aa = { "@parameter.outer", "around argument" },
                ia = { "@parameter.inner", "inside argument" },
                al = { "@loop.outer", "around loop" },
                il = { "@loop.inner", "inside loop" },
                ai = { "@conditional.outer", "around conditional" },
                ii = { "@conditional.inner", "inside conditional" },
            }
            for lhs, spec in pairs(objects) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    select.select_textobject(spec[1], "textobjects")
                end, { desc = spec[2] })
            end

            local move = require("nvim-treesitter-textobjects.move")
            local moves = {
                ["]f"] = { move.goto_next_start, "@function.outer", "next function" },
                ["]c"] = { move.goto_next_start, "@class.outer", "next class" },
                ["[f"] = { move.goto_previous_start, "@function.outer", "prev function" },
                ["[c"] = { move.goto_previous_start, "@class.outer", "prev class" },
            }
            for lhs, spec in pairs(moves) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    spec[1](spec[2], "textobjects")
                end, { desc = spec[3] })
            end
        end,
    },
}
