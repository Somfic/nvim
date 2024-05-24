return {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    config = function()
		vim.api.nvim_create_autocmd("BufReadPre", {
			callback = function()
                vim.api.nvim_command("NoNeckPain")
				-- vim.api.nvim_command("NoNeckPainResize 80")
			end,
		})
		vim.keymap.set("n", "zen", ":NoNeckPainResize 80<CR>")
    end,
}
