--[[
--Script for installing mini.deps plugin manager if not found. 
--
--This can be deleted once migrating to built in plugin manager in Neovim 0.12
--]]
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/nvim-mini/mini.nvim",
		mini_path,
	})
	vim.cmd("packadd mini.nvim | helptags ALL")
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

local deps = require("mini.deps")
deps.setup({ path = { package = path_package } })

local add = deps.add
add("stevearc/conform.nvim")
add("tpope/vim-surround")
add("neovim/nvim-lspconfig")
add("EskelinenAntti/omarchy-theme-loader.nvim")
add("ibhagwan/fzf-lua")
add({
	source = "nvim-treesitter/nvim-treesitter",
	checkout = "main",
	monitor = "main",
	hook = {
		post_checkout = function()
			vim.cmd("TSUpdate")
		end,
	},
})
add({ source = "nvim-treesitter/nvim-treesitter-textobjects", checkout = "main", monitor = "main" })

deps.snap_load()
