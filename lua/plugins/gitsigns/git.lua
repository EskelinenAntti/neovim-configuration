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

return {
	---@param cwd string
	---@return string?, string?
	rev_parse = function(cwd)
		return run(cwd, { "rev-parse", "--show-toplevel" })
	end,
	---@param root string
	---@param left string
	---@param right string
	---@return string?, string?
	merge_base = function(root, left, right)
		return run(root, { "merge-base", left, right })
	end,
}
