require("oil").setup({
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			return name == ".."
		end,
	},
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open file explorer" })
