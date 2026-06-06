require("diffview").setup({
	use_icons = false,
	default_args = {
		DiffviewOpen = { "--imply-local" },
	},
})

local diffview = require("diffview.lib")
vim.keymap.set("n", "<leader>g", function()
	local view = diffview.get_current_view()
	if view then
		vim.cmd("DiffviewClose")
	else
		vim.cmd("DiffviewOpen")
	end
end, { desc = "Toggle Diffview" })
