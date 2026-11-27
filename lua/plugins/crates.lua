return {
    {
        "Saecki/crates.nvim",
        tag = "stable",
        -- queries the crates.io API directly; no cargo/rust toolchain needed
        event = { "BufRead Cargo.toml" },
        config = function()
            local crates = require("crates")
            crates.setup({
                lsp = {
                    -- act as a pseudo-LSP for hover (K), code actions and completion
                    -- (blink.cmp picks the completions up through its lsp source)
                    enabled = true,
                    actions = true,
                    completion = true,
                    hover = true,
                },
            })

            vim.api.nvim_create_autocmd("BufRead", {
                pattern = "Cargo.toml",
                callback = function()
                    local map = function(lhs, fn, desc)
                        vim.keymap.set("n", lhs, fn, { buffer = true, desc = desc, silent = true })
                    end
                    map("K", crates.show_popup, "Crates: details popup")
                    map("<leader>cv", crates.show_versions_popup, "Crates: show versions")
                    map("<leader>cf", crates.show_features_popup, "Crates: show features")
                    map("<leader>cu", crates.update_crate, "Crates: update to compatible")
                    map("<leader>cU", crates.upgrade_crate, "Crates: upgrade to latest")
                    map("<leader>ca", crates.update_all_crates, "Crates: update all")
                    map("<leader>cA", crates.upgrade_all_crates, "Crates: upgrade all to latest")
                end,
            })
        end,
    },
}
