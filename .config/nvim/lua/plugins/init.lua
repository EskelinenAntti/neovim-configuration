vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add({
	"https://github.com/sainnhe/gruvbox-material",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/tpope/vim-surround",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
})

vim.api.nvim_create_user_command("CleanPlugins", function()
	vim.pack.del(vim.iter(vim.pack.get())
		:filter(function(x)
			return not x.active
		end)
		:map(function(x)
			return x.spec.name
		end)
		:totable())
end, { desc = "Delete inactive plugins" })

require("plugins.nvim-treesitter")
require("plugins.nvim-lspconfig")
require("plugins.conform")
require("plugins.fzf-lua")
require("plugins.notes")
require("plugins.gruvbox-material")
