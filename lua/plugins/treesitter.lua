return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        -- main branch does not support lazy-loading
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup()

            local ensure_installed = {
                "lua",
                "vim",
                "vimdoc",
                "javascript",
                "typescript",
                "tsx",
                "json",
                "html",
                "css",
                "scss",
                "svelte",
                "rust",
                "python",
                "go",
                "c",
                "c_sharp",
                "markdown",
                "markdown_inline",
            }
            require("nvim-treesitter").install(ensure_installed)

            local ts = require("nvim-treesitter")

            -- Set of parsers that actually exist, computed once. Used to avoid
            -- trying to start/install a parser for plugin UI filetypes that map
            -- to no real grammar (e.g. "notify", "noice").
            local available
            local function is_available(lang)
                if not available then
                    available = {}
                    for _, l in ipairs(require("nvim-treesitter.config").get_available()) do
                        available[l] = true
                    end
                end
                return available[lang]
            end

            -- main branch has no modules: highlight/indent are wired up by hand.
            -- (incremental selection and the matchup module no longer exist here;
            --  vim-matchup still works standalone via lua/plugins/matchup.lua.)
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local buf = args.buf
                    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
                    if not lang or not is_available(lang) then
                        return
                    end

                    if pcall(vim.treesitter.start, buf, lang) then
                        -- experimental treesitter-based indentation
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    else
                        -- parser missing: install async (auto_install). Highlighting
                        -- kicks in the next time a file of this type is opened.
                        pcall(ts.install, { lang })
                    end
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")

            local function map(mode, lhs, fn, desc)
                vim.keymap.set(mode, lhs, fn, { desc = desc, silent = true })
            end

            -- select
            map({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end, "around function")
            map({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end, "inside function")
            map({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end, "around class")
            map({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end, "inside class")
            map({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end, "around argument")
            map({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end, "inside argument")
            map({ "x", "o" }, "al", function() select.select_textobject("@loop.outer", "textobjects") end, "around loop")
            map({ "x", "o" }, "il", function() select.select_textobject("@loop.inner", "textobjects") end, "inside loop")
            map({ "x", "o" }, "ai", function() select.select_textobject("@conditional.outer", "textobjects") end, "around conditional")
            map({ "x", "o" }, "ii", function() select.select_textobject("@conditional.inner", "textobjects") end, "inside conditional")

            -- move
            map({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, "next function")
            map({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end, "next class")
            map({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, "prev function")
            map({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, "prev class")
        end,
    },
}
