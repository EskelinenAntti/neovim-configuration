vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" })

local fzfLua = require("fzf-lua")

fzfLua.setup({
	files = {
		formatter = "path.filename_first",
	},
	grep = {
		rg_opts = "--hidden --line-number --column --no-heading --smart-case --color=never --glob=!node_modules/* --glob=!.git/* --glob=!build/* --glob=!package-lock.json",
		formatter = "path.filename_first",
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
