vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gitsigns = require("gitsigns")
gitsigns.setup({
	attach_to_untracked = true,
})

vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk_inline, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff file against base" })

local git = require("plugins.gitsigns.git")
local gh = require("plugins.gitsigns.gh")

---@param message string|nil
local function notify(message)
	if message ~= nil then
		vim.notify("Review: " .. message, vim.log.levels.ERROR)
	else
		vim.notify("Review: unexpected error occurred.", vim.log.levels.ERROR)
	end
end

---@param base string
local function review_against_commit(base)
	gitsigns.change_base(base, true, function(gitsigns_err)
		if gitsigns_err then
			notify(gitsigns_err)
			return
		end
		gitsigns.setqflist("all")
	end)
end

---@param repository string
local function review_against_pr(repository)
	gh.pr_view(repository, function(base_oid, gh_err)
		if not base_oid or gh_err then
			notify(gh_err)
			return
		end
		local base, err = git.merge_base(repository, "HEAD", base_oid)
		if not base or err then
			notify(err)
			return
		end
		review_against_commit(base)
	end)
end

---@param root string
local function review_against_branch(root)
	local base, err = git.branch_base(root)
	if not base then
		notify(err)
		return
	end
	review_against_commit(base)
end

---@param root string
local function review(root)
	gh.pr_view(root, function(base_oid)
		if base_oid and base_oid ~= "" then
			local base = git.merge_base(root, "HEAD", base_oid)
			if base then
				review_against_commit(base)
				return
			end
		end

		local base = git.branch_base(root)
		if base then
			review_against_commit(base)
			return
		end

		review_against_commit("HEAD")
	end)
end

vim.api.nvim_create_user_command("Review", function(opts)
	local mode = opts.fargs[1]
	if mode and mode ~= "pr" and mode ~= "branch" and mode ~= "local" then
		notify("Usage: Review [pr|branch|local]")
		return
	end

	local filename = vim.api.nvim_buf_get_name(0)
	local cwd = filename ~= "" and vim.fn.filereadable(filename) == 1 and vim.fs.dirname(filename) or vim.fn.getcwd()
	local root, err = git.rev_parse(cwd)
	if not root then
		notify(err)
		return
	end
	if mode == "pr" then
		review_against_pr(root)
	elseif mode == "branch" then
		review_against_branch(root)
	elseif mode == "local" then
		review_against_commit("HEAD")
	else
		review(root)
	end
end, {
	nargs = "?",
	desc = "Review PR, branch, or local changes",
	complete = function(arglead)
		return vim.tbl_filter(function(mode)
			return vim.startswith(mode, arglead)
		end, { "pr", "branch", "local" })
	end,
})
