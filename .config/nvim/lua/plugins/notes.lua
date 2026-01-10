local M = {}

---Build os date objects with given time or current time if not provided.
---@param time integer?
---@return osdate
local function osdate(time)
	return os.date("*t", time) --[[@as osdate]]
end

---osdate parsed from current buffer name or nil if it could not be parsed
---@return osdate|nil
local function get_buffer_date()
	local filename = vim.fn.expand("%:t")
	local y, m, d = filename:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
	local date = { year = tonumber(y), month = tonumber(m), day = tonumber(d) }
	if not (date.year and date.month and date.day) then
		return nil
	end

	return osdate(os.time(date))
end

---Open daily note for given date
---@param date osdate|nil
M.open_daily_note = function(date)
	if not date then
		date = osdate()
	end
	vim.cmd.edit(vim.fs.joinpath("daily", os.date("%Y-%m-%d", os.time(date)) .. ".md"))
end

---Open next/previous daily note with given offset of days to currently open note or current day
---@param offset integer Offset from the current day or note that is currently open. 1 meaning tomorrow, -1 yesterday, for example.
local function open_daily_at_offset(offset)
	local base = get_buffer_date()
	if not base then
		base = osdate()
	end

	base.day = base.day + offset
	M.open_daily_note(base)
end

M.open_yesterday = function()
	open_daily_at_offset(-1)
end

M.open_tomorrow = function()
	open_daily_at_offset(1)
end

vim.api.nvim_create_user_command("Today", function()
	M.open_daily_note()
end, {})

vim.api.nvim_create_user_command("Yesterday", function()
	M.open_yesterday()
end, {})

vim.api.nvim_create_user_command("Tomorrow", function()
	M.open_tomorrow()
end, {})

return M
