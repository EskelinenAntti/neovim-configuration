vim.pack.add({
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/EskelinenAntti/omarchy-theme.nvim",
})

if require("omarchy-theme.environment").is_omarchy() then
	vim.cmd.colorscheme("omarchy")
else
	require("kanagawa").setup({
		colors = {
			theme = {
				all = {
					ui = { bg_gutter = "none" },
				},
			},
		},
	})
	vim.cmd.colorscheme("kanagawa-dragon")
end
