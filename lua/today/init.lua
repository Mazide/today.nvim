local M = {}

local plugin_root = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h:h")
local default_opts = {
	templatepath = plugin_root .. "/template.md",
	folderpath = nil,

	window = {
		width = 0.7,
		height = 0.7,
		border = "rounded",
		title = "Today",
		title_pos = "center",
		padding = 1,
	},
}

M.config = {}

local state = {
	win = nil,
	buf = nil,
}

M.setup = function(opt)
	M.config = vim.tbl_deep_extend("force", default_opts, opt or {})
	vim.api.nvim_create_user_command("TodayOpen", M.open_today, {})
	vim.api.nvim_create_user_command("TodayToggle", M.toogle_today, {})
end

local function get_win_config()
	local win_conf = M.config.window
	local total_cols = vim.o.columns
	local total_lines = vim.o.lines
	local width = math.floor(total_cols * win_conf.width)
	local height = math.floor(total_lines * win_conf.height)
	local col = math.floor((total_cols - width) / 2)
	local row = math.floor((total_lines - height) / 2)
	return {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = win_conf.border,
		title = win_conf.title,
		title_pos = win_conf.title_pos,
	}
end

local function close_window()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
end

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local function read_template()
	local fullPath = vim.fn.expand(M.config.templatepath)
	local input = io.open(fullPath, "r")
	if not input then
		return
	end

	local content = input:read("*all")
	input:close()
	return content
end

local function create_today_file_if_not_exists()
	local template = read_template()
	local date = os.date("%Y-%m-%d")

	if M.config.folderpath == nil then
		print("Please set folderpath in config")
		return ""
	end

	local fullFolderPath = vim.fn.expand(M.config.folderpath)
	local filePath = fullFolderPath .. date .. ".md"
	if file_exists(filePath) == false then
		local file, err = io.open(filePath, "a")
		if not file then
			print("Error creating Today file: " .. err)
			return ""
		end

		file:write(template)
		file:close()
		print("Today: " .. filePath)
	end

	return filePath
end

local function create_bindings()
	vim.keymap.set("n", "q", function()
		if vim.api.nvim_get_current_win() == state.win then
			close_window()
		else
			vim.cmd("normal! q")
		end
	end, { buffer = state.buf, nowait = true, silent = true })

	-- TODO move under options
	vim.api.nvim_create_autocmd("WinLeave", {
		buffer = state.buf,
		callback = function()
			vim.cmd("silent! w")
		end,
	})
end

M.open_today = function()
	local filePath = create_today_file_if_not_exists()
	if filePath == "" then
		return
	end

	vim.cmd("edit " .. vim.fn.fnameescape(filePath))
end

M.toogle_today = function()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
		state.win = nil
		return
	end

	local filePath = create_today_file_if_not_exists()
	if filePath == "" then
		return
	end

	if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
		state.buf = vim.fn.bufadd(filePath)
		vim.fn.bufload(state.buf)
	end

	local win_config = get_win_config()
	state.win = vim.api.nvim_open_win(state.buf, true, win_config)

	create_bindings()
end

return M
