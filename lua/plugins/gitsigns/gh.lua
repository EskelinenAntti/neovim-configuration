return {
	---@type fun(repository: string, callback: fun(base_oid: string?, err: string?))
	pr_view = function(repository, callback)
		if vim.fn.executable("gh") ~= 1 then
			callback(nil, "gh cli not found")
			return
		end
		vim.system(
			{ "gh", "pr", "view", "--json", "baseRefOid", "--jq", ".baseRefOid" },
			{
				cwd = repository,
				text = true,
			},
			vim.schedule_wrap(function(result)
				if result.code ~= 0 then
					callback(nil, vim.trim(result.stderr))
					return
				end
				callback(vim.trim(result.stdout), nil)
			end)
		)
	end,
}
