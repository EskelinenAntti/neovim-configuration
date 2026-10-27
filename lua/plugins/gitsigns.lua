vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gitsigns = require("gitsigns")
gitsigns.setup({
	attach_to_untracked = true,
})

vim.keymap.set("n", "<leader>g", gitsigns.preview_hunk_inline)
vim.keymap.set("n", "<leader>G", gitsigns.reset_hunk, { desc = "Reset hunk" })

local function review_error(message)
	vim.notify("Review: " .. tostring(message), vim.log.levels.ERROR)
end

local function git(cwd, args)
	local command = { "git", "-C", cwd }
	vim.list_extend(command, args)
	local result = vim.system(command, { text = true }):wait()
	if result.code == 0 then
		return vim.trim(result.stdout)
	end
	return nil, vim.trim(result.stderr)
end

local function review_base(base)
	gitsigns.change_base(base, true, function(change_err)
		if change_err then
			review_error(change_err)
			return
		end
		gitsigns.setqflist("all")
	end)
end

local function review_pr(root)
	if vim.fn.executable("gh") ~= 1 then
		review_error("gh cli not found")
		return
	end

	vim.system({ "gh", "pr", "view", "--json", "baseRefOid", "--jq", ".baseRefOid" }, {
		cwd = root,
		text = true,
	}, vim.schedule_wrap(function(result)
		if result.code ~= 0 then
			review_error(vim.trim(result.stderr))
			return
		end
		review_base(vim.trim(result.stdout))
	end))
end

vim.api.nvim_create_user_command("Review", function(opts)
	local mode = opts.fargs[1] or "pr"
	if mode ~= "pr" and mode ~= "local" then
		review_error("Usage: Review [local|pr]")
		return
	end

	local filename = vim.api.nvim_buf_get_name(0)
	local cwd = filename ~= "" and vim.fn.filereadable(filename) == 1 and vim.fs.dirname(filename) or vim.fn.getcwd()
	local root, err = git(cwd, { "rev-parse", "--show-toplevel" })
	if not root then
		review_error(err)
		return
	end
	if mode == "pr" then
		review_pr(root)
	else
		review_base("HEAD")
	end
end, {
	nargs = "?",
	desc = "Review local or PR changes",
})
