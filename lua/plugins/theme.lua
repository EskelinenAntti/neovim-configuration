vim.pack.add({
	"https://github.com/webhooked/kanso.nvim",
	"https://github.com/EskelinenAntti/omarchy-theme.nvim",
})

if require("omarchy-theme.environment").is_omarchy() then
	vim.cmd.colorscheme("omarchy")
else
	vim.cmd.colorscheme("kanso-zen")
end
