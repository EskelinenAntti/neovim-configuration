require("diffview").setup({
	use_icons = false,
	default_args = {
		DiffviewOpen = { "--imply-local" },
	},
})

vim.keymap.set("n", "<leader>g", function()
	vim.cmd("DiffviewOpen")
end, { desc = "Toggle Diffview" })
