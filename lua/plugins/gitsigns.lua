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

local function default_branch(root)
	local remote_head = git(root, { "symbolic-ref", "--quiet", "refs/remotes/origin/HEAD" })
	if remote_head then
		return remote_head
	end
	for _, name in ipairs({ "origin/main", "origin/master", "main", "master" }) do
		if git(root, { "rev-parse", "--verify", "--quiet", name .. "^{commit}" }) then
			return name
		end
	end
end

local function review_base(base)
	-- The global base also applies to files that have not been opened yet.
	gitsigns.change_base(base, true, function(change_err)
		if change_err then
			review_error(change_err)
			return
		end
		gitsigns.setqflist("all")
	end)
end

local function review_commits(root, source, target)
	local base, err = git(root, { "merge-base", "--", source, target })
	if not base then
		review_error(err ~= "" and err or "no merge base")
		return
	end
	review_base(base)
end

local function fetch_pr(root, pr)
	local repository = pr.url:gsub("/pull/%d+$", "")
	vim.system({ "git", "-C", root, "fetch", "--no-tags", "--", repository, pr.baseRefOid, pr.headRefOid }, {
		text = true,
	}, vim.schedule_wrap(function(result)
		if result.code ~= 0 then
			review_error(vim.trim(result.stderr))
			return
		end
		review_commits(root, pr.headRefOid, pr.baseRefOid)
	end))
end

local function review_pr(root)
	if vim.fn.executable("gh") ~= 1 then
		review_error("gh not found")
		return
	end

	vim.system({ "gh", "pr", "view", "--json", "baseRefOid,headRefOid,url" }, {
		cwd = root,
		text = true,
	}, vim.schedule_wrap(function(result)
		if result.code ~= 0 then
			review_error(vim.trim(result.stderr))
			return
		end
		local pr = vim.json.decode(result.stdout)
		local base = git(root, { "merge-base", "--", pr.headRefOid, pr.baseRefOid })
		if base then
			review_base(base)
		else
			fetch_pr(root, pr)
		end
	end))
end

vim.api.nvim_create_user_command("Review", function(opts)
	local mode = opts.fargs[1] or "pr"
	local max_args = mode == "branch" and 2 or 1
	if not vim.tbl_contains({ "pr", "local", "branch" }, mode) or #opts.fargs > max_args then
		review_error("Usage: Review [pr|local|branch [base_branch]]")
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
	elseif mode == "local" then
		review_base("HEAD")
	else
		local branch = opts.fargs[2] or default_branch(root)
		if not branch then
			review_error("no default branch; use :Review branch <base_branch>")
		else
			review_commits(root, "HEAD", branch)
		end
	end
end, {
	nargs = "*",
	desc = "Review PR, local, or branch changes",
	complete = function(lead, line)
		local args = vim.split(line, "%s+", { trimempty = true })
		local choices = {}
		if #args <= 2 and not line:match("^%s*Review%s+%S+%s+") then
			choices = { "pr", "local", "branch" }
		elseif args[2] == "branch" then
			local branches =
				git(vim.fn.getcwd(), { "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" })
			choices = branches and vim.split(branches, "\n", { trimempty = true }) or {}
		end
		return vim.tbl_filter(function(choice)
			return vim.startswith(choice, lead)
		end, choices)
	end,
})
