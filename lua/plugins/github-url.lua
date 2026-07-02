local function repo()
	return vim.trim(vim.fn.system({ "gh", "repo", "view", "--json", "url", "-q", ".url" }))
end

local function brand()
	return vim.trim(vim.fn.system({ "git", "branch", "--show-current" }))
end

local function file()
	return vim.fn.expand("%:.")
end

local function line_range(first_line, last_line)
	last_line = last_line or first_line
	first_line, last_line = math.min(first_line, last_line), math.max(first_line, last_line)
	local range = ("#L%d"):format(first_line)
	if first_line ~= last_line then
		range = ("%s-L%d"):format(range, last_line)
	end
	return range
end

local function copy_github_url(first_line, last_line)
	local url = ("%s/blob/%s/%s%s"):format(repo(), brand(), file(), line_range(first_line, last_line))
	return vim.fn.setreg("+", url)
end

vim.keymap.set("n", "gy", function()
	local current_line = vim.fn.line(".")
	vim.schedule(function()
		copy_github_url(current_line)
	end)
end, { desc = "Copy GitHub URL" })

vim.keymap.set("x", "gy", function()
	local first_line, last_line = vim.fn.line("v"), vim.fn.line(".")
	vim.schedule(function()
		copy_github_url(first_line, last_line)
	end)
	vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
end, { desc = "Copy GitHub URL" })
