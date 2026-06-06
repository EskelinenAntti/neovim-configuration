require("diffview").setup({
	use_icons = false,
	default_args = {
		DiffviewOpen = { "--imply-local" },
	},
})

vim.keymap.set("n", "<leader>g", function()
	vim.cmd("DiffviewOpen")
end, { desc = "Toggle Diffview" })

vim.api.nvim_create_autocmd({ "FocusGained" }, {
	callback = function()
		if vim.fn.exists(":DiffviewRefresh") == 2 then
			vim.cmd("silent! DiffviewRefresh")
		end
	end,
})
