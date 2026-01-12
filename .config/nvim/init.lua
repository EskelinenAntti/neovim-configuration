vim.g.mapleader = " "
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.opt.guicursor = ""
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.completeopt = { "menuone", "noselect", "popup" }
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = -1
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.list = true
vim.opt.listchars:append({ trail = "_" })
vim.opt.clipboard:append("unnamedplus")
vim.keymap.set("n", "<leader>e", "<cmd>Ex<cr>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>g", function()
	vim.cmd.terminal("lazygit")
	vim.cmd("startinsert")
end, { desc = "Open lazygit" })

require("plugins")
