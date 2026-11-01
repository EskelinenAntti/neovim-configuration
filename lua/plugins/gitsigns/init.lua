vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })

local gitsigns = require("gitsigns")
gitsigns.setup({
	attach_to_untracked = true,
})

vim.keymap.set("n", "<leader>g", gitsigns.preview_hunk_inline)
vim.keymap.set("n", "<leader>G", gitsigns.reset_hunk, { desc = "Reset hunk" })

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
local function review(root)
	gh.pr_view(root, function(base_oid, gh_err)
		if not base_oid or gh_err then
			if gh_err and gh_err:find("no pull requests found", 1, true) then
				review_against_commit("HEAD")
			else
				notify(gh_err)
			end
			return
		end
		local base, err = git.merge_base(root, "HEAD", base_oid)
		if not base or err then
			notify(err)
			return
		end
		review_against_commit(base)
	end)
end

vim.api.nvim_create_user_command("Review", function(opts)
	local mode = opts.fargs[1]
	if mode and mode ~= "pr" and mode ~= "local" then
		notify("Usage: Review [local|pr]")
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
	elseif mode == "local" then
		review_against_commit("HEAD")
	else
		review(root)
	end
end, {
	nargs = "?",
	desc = "Review local or PR changes",
})
