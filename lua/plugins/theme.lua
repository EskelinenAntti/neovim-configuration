vim.pack.add({
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/EskelinenAntti/omarchy-theme.nvim",
})

if require("omarchy-theme.environment").is_omarchy() then
	vim.cmd.colorscheme("omarchy")
else
	vim.cmd.colorscheme("tokyonight-night")
end
