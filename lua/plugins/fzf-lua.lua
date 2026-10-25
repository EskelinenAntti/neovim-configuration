vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzfLua = require("fzf-lua")

fzfLua.setup({
	winopts = {
		preview = {
			layout = "vertical",
			vertical = "down:50%",
			hidden = false,
		},
	},
	grep = {
		rg_opts = "--hidden --line-number --column --no-heading --smart-case --color=never --glob=!node_modules/* --glob=!.git/* --glob=!build/* --glob=!package-lock.json",
	},
	keymap = {
		fzf = {
			["alt-a"] = "select-all+accept",
			["ctrl-u"] = "half-page-up",
			["ctrl-d"] = "half-page-down",
		},
	},
})

vim.keymap.set("n", "<leader>f", fzfLua.files, { desc = "Fuzzy find files" })
vim.keymap.set("n", "<leader>b", fzfLua.buffers, { desc = "Fuzzy find buffers" })
vim.keymap.set("n", "<leader>/", fzfLua.live_grep, { desc = "Grep" })
vim.keymap.set("v", "<leader>/", fzfLua.grep_visual, { desc = "Grep selection" })
vim.keymap.set("n", "<leader>*", fzfLua.grep_cword, { desc = "Grep cword" })
