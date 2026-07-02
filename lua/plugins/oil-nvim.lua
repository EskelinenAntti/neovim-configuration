require("oil").setup({
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name, _)
			return name == ".."
		end,
	},
	confirmation = {
		border = "rounded",
	},
	skip_confirm_for_simple_edits = true,
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open file explorer" })

vim.g.loaded_netrwPlugin = 1
