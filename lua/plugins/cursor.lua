-- Cursor animation only; smooth scrolling is snacks.scroll (snacks.lua)
return {
    {
        "echasnovski/mini.animate",
        version = false,
        event = "VeryLazy",
        init = function()
            -- No animations while the mouse wheel/touchpad scrolls or hjkl is held:
            -- each repeat would restart the smooth scroll from wherever the last one
            -- had got to, and the cursor would animate every step, so it jitters.
            -- Both come back 150ms after the last repeat; one-off jumps (<C-d>, gg,
            -- ...) stay animated.
            local timer = assert(vim.uv.new_timer())
            local function unanimated(key)
                return function()
                    vim.g.snacks_scroll = false
                    vim.g.minianimate_disable = true
                    timer:stop()
                    timer:start(150, 0, vim.schedule_wrap(function()
                        vim.g.snacks_scroll = nil
                        vim.g.minianimate_disable = nil
                    end))
                    return key
                end
            end
            for _, key in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>" }) do
                vim.keymap.set({ "n", "x", "i" }, key, unanimated(key), { expr = true, desc = "Scroll (unanimated)" })
            end
            for _, key in ipairs({ "h", "j", "k", "l" }) do
                vim.keymap.set({ "n", "x" }, key, unanimated(key), { expr = true })
            end
        end,
        config = function()
            local animate = require("mini.animate")
            animate.setup({
                cursor = {
                    enable = true,
                    timing = animate.gen_timing.exponential({
                        easing = "out",
                        duration = 120,
                        unit = "total",
                    }),
                    path = animate.gen_path.line({
                        predicate = function()
                            return vim.bo.filetype ~= "oil"
                        end,
                    }),
                },
                scroll = { enable = false },
                resize = { enable = false },
                open = { enable = false },
                close = { enable = false },
            })
        end,
    },
}
