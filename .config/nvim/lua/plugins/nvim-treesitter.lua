require("nvim-treesitter")
	.install({
		"typescript",
		"tsx",
		"html",
		"go",
		"markdown",
		"markdown_inline",
		"json",
		"yaml",
		"python",
	})
	:wait()

local ts_filetypes = {}
for _, installed in ipairs(require("nvim-treesitter.config").get_installed()) do
	for _, ft in ipairs(vim.treesitter.language.get_filetypes(installed)) do
		table.insert(ts_filetypes, ft)
	end
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = ts_filetypes,
	callback = function()
		vim.treesitter.start()
	end,
})

---Register keymap for selecting a text object
---@param key string key to press after i (for inner scopes) or a (outer scope).
---@param textobject string text object to select
local function register_text_object_keymap(key, textobject)
	vim.keymap.set({ "x", "o" }, "a" .. key, function()
		require("nvim-treesitter-textobjects.select").select_textobject("@" .. textobject .. ".outer", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "i" .. key, function()
		require("nvim-treesitter-textobjects.select").select_textobject("@" .. textobject .. ".inner", "textobjects")
	end)
end

register_text_object_keymap("f", "function")
register_text_object_keymap("b", "block")
register_text_object_keymap("s", "class")
register_text_object_keymap("c", "comment")
