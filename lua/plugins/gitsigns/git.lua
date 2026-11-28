assert(vim.fn.executable("git") == 1, "git cli not found")

---@param cwd string
---@param args string[]
---@return string?, string?
local function run(cwd, args)
	local command = { "git", "-C", cwd }
	vim.list_extend(command, args)
	local result = vim.system(command, { text = true }):wait()
	if result.code == 0 then
		return vim.trim(result.stdout)
	end
	return nil, vim.trim(result.stderr)
end

---@param root string
---@param left string
---@param right string
---@return string?, string?
local function merge_base(root, left, right)
	return run(root, { "merge-base", left, right })
end

return {
	---@param cwd string
	---@return string?, string?
	rev_parse = function(cwd)
		return run(cwd, { "rev-parse", "--show-toplevel" })
	end,
	merge_base = merge_base,
	---@param root string
	---@return string?, string?
	branch_base = function(root)
		local origin_head = run(root, { "symbolic-ref", "refs/remotes/origin/HEAD" })
		local default_branch = origin_head and origin_head:match("^refs/remotes/origin/(.+)$")
		local candidates = default_branch and { default_branch } or { "main", "master" }
		for _, branch in ipairs(candidates) do
			local ref = "refs/heads/" .. branch
			if run(root, { "show-ref", "--verify", "--quiet", ref }) then
				local base, err = merge_base(root, "HEAD", ref)
				if err == "" then
					err = "HEAD and " .. branch .. " have no common ancestor."
				end
				return base, err
			end
		end
		return nil, "Could not find a local default branch."
	end,
}
