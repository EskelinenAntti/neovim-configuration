vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gitsigns = require("gitsigns")
gitsigns.setup({
	attach_to_untracked = true,
})

vim.keymap.set("n", "<leader>g", gitsigns.preview_hunk_inline)

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

vim.api.nvim_create_user_command("Review", function(opts)
	local mode = opts.fargs[1] or "branch"
	if (mode ~= "local" and mode ~= "branch") or (mode == "local" and opts.fargs[2]) or #opts.fargs > 2 then
		vim.notify("Usage: Review [local|branch] [base_branch]", vim.log.levels.ERROR)
		return
	end

	local filename = vim.api.nvim_buf_get_name(0)
	local cwd = filename ~= "" and vim.fn.filereadable(filename) == 1 and vim.fs.dirname(filename) or vim.fn.getcwd()
	local root, err = git(cwd, { "rev-parse", "--show-toplevel" })
	if not root then
		vim.notify("Review: " .. err, vim.log.levels.ERROR)
		return
	end

	local base = "HEAD"
	if mode == "branch" then
		local branch = opts.fargs[2] or default_branch(root)
		if not branch then
			vim.notify("Review: cannot detect default branch; use :Review branch <base_branch>", vim.log.levels.ERROR)
			return
		end
		local revision
		revision, err = git(root, { "rev-parse", "--verify", "--end-of-options", branch .. "^{commit}" })
		if revision then
			base, err = git(root, { "merge-base", "HEAD", revision })
		else
			base = nil
		end
		if not base then
			vim.notify("Review: " .. err, vim.log.levels.ERROR)
			return
		end
	end

	-- The global base also applies to files that have not been opened yet.
	gitsigns.change_base(base, true, function(change_err)
		if change_err then
			vim.notify("Review: " .. tostring(change_err), vim.log.levels.ERROR)
			return
		end
		gitsigns.setqflist("all")
	end)
end, {
	nargs = "*",
	desc = "Review local or branch changes in the Gitsigns quickfix list",
	complete = function(lead, line)
		local args = vim.split(line, "%s+", { trimempty = true })
		local choices = {}
		if #args <= 2 and not line:match("^%s*Review%s+%S+%s+") then
			choices = { "local", "branch" }
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
