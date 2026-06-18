return {
    {
        "vuki656/package-info.nvim",
        dependencies = { "MunifTanjim/nui.nvim" },
        -- needs a package manager (npm/yarn/pnpm/bun) on PATH to query the registry
        event = { "BufRead package.json" },
        config = function()
            local pi = require("package-info")
            pi.setup({
                autostart = true,        -- show versions automatically
                hide_up_to_date = false, -- also annotate deps already on latest
                -- install/update/delete use bun; version display always shells out
                -- to `npm outdated`, so hints only appear when npm is on PATH
                -- (i.e. inside a dev-shell that provides node). Auto-detected from
                -- bun.lock / yarn.lock / package-lock.json when present.
                package_manager = "bun",
            })

            vim.api.nvim_create_autocmd("BufRead", {
                pattern = "package.json",
                callback = function()
                    local map = function(lhs, fn, desc)
                        vim.keymap.set("n", lhs, fn, { buffer = true, desc = desc, silent = true })
                    end
                    map("<leader>ns", pi.show, "Packages: show versions")
                    map("<leader>nc", pi.change_version, "Packages: change version")
                    map("<leader>nu", pi.update, "Packages: update dependency")
                    map("<leader>ni", pi.install, "Packages: install new dependency")
                    map("<leader>nd", pi.delete, "Packages: delete dependency")
                end,
            })
        end,
    },
}
