local channel

local function host()
	if channel then
		return channel
	end

	channel = vim.fn.jobstart({ "review-my-slop", "code", "--nvim" }, { rpc = true })
	if channel <= 0 then
		channel = nil
		error("failed to start review-my-slop RPC host")
	end
	return channel
end

vim.api.nvim_create_user_command("ReviewMySlopCode", function(args)
	vim.rpcrequest(host(), "review-my-slop/v1/code/comment/init", { args.line1, args.line2 })
end, { range = true, desc = "Review code with review-my-slop" })

vim.api.nvim_create_autocmd("BufWriteCmd", {
	pattern = "review-my-slop://comment/*",
	callback = function(args)
		vim.rpcrequest(host(), "review-my-slop/v1/code/comment/submit", args.buf)
	end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
	pattern = "review-my-slop://comment/*",
	callback = function(args)
		if channel then
			pcall(vim.rpcnotify, channel, "review-my-slop/v1/code/comment/discard", args.buf)
		end
	end,
})

vim.keymap.set("n", "<leader>c", "<cmd>ReviewMySlopCode<cr>", { desc = "Review code with review-my-slop" })
vim.keymap.set("x", "<leader>c", ":ReviewMySlopCode<cr>", { desc = "Review code with review-my-slop" })
