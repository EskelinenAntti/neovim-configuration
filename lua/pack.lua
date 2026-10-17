local function inactive_plugins()
	return vim.iter(vim.pack.get())
		:filter(function(x)
			return not x.active
		end)
		:map(function(x)
			return x.spec.name
		end)
		:totable()
end

vim.api.nvim_create_user_command("PackClean", function()
	vim.pack.del(inactive_plugins())
end, { desc = "Delete inactive plugins" })

vim.api.nvim_create_user_command("PackUpdate", function()
	vim.pack.update()
end, { desc = "Update plugins" })
