local M = {}

local sep = vim.loop.os_uname().sysname:match("Windows") and "\\" or "/"

local plugin_root = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h:h")
local default_opts = {
	templatepath = plugin_root .. "/template.md",
	folderpath = nil,
	autosave = true,
	window = {
		width = 0.7,
		height = 0.7,
		border = "rounded",
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

	vim.api.nvim_create_user_command("Today", function()
		M.open_period("%Y-%m-%d")
	end, {})

	vim.api.nvim_create_user_command("TodayOpen", function()
		M.open_period("%Y-%m-%d")
	end, {})
	vim.api.nvim_create_user_command("TodayToggle", function()
		M.toggle_period("%Y-%m-%d")
	end, {})

	vim.api.nvim_create_user_command("MonthOpen", function()
		M.open_period("%Y-%m")
	end, {})
	vim.api.nvim_create_user_command("MonthToggle", function()
		M.toggle_period("%Y-%m")
	end, {})

	vim.api.nvim_create_user_command("YearOpen", function()
		M.open_period("%Y")
	end, {})
	vim.api.nvim_create_user_command("YearToggle", function()
		M.toggle_period("%Y")
	end, {})
end

local function get_win_config(title)
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
		title = title or " Note ",
		title_pos = win_conf.title_pos,
	}
end

local function close_window()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
end

local function read_template()
	local fullPath = vim.fn.expand(M.config.templatepath)
	local input = io.open(fullPath, "r")
	if not input then
		return ""
	end
	local content = input:read("*all")
	input:close()
	return content
end

local function create_file_if_not_exists(date)
	if M.config.folderpath == nil then
		vim.notify("Today.nvim: Please set folderpath in config", vim.log.levels.ERROR)
		return nil
	end

	local folder = vim.fn.expand(M.config.folderpath)
	if not folder:match("[\\/]$") then
		folder = folder .. "/"
	end

	if vim.fn.isdirectory(folder) == 0 then
		vim.fn.mkdir(folder, "p")
	end

	local filePath = folder .. date .. ".md"

	if vim.fn.filereadable(filePath) == 0 then
		local template = read_template()
		local file, err = io.open(filePath, "w")
		if not file then
			vim.notify("Today.nvim: Error creating file: " .. err, vim.log.levels.ERROR)
			return nil
		end
		file:write(template)
		file:close()
	end

	return filePath
end

local function create_bindings(bufnr, autosave)
	vim.keymap.set("n", "q", function()
		close_window()
	end, { buffer = bufnr, nowait = true, silent = true })

	if autosave then
		local group = vim.api.nvim_create_augroup("TodayAutosave", { clear = false })
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
		vim.api.nvim_create_autocmd("WinLeave", {
			buffer = bufnr,
			group = group,
			callback = function()
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.cmd("silent! write")
				end
			end,
		})
	end
end

M.toggle_file = function(filePath)
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
		state.win = nil
		return
	end

	if not filePath then
		return
	end

	state.buf = vim.fn.bufadd(filePath)

	if not vim.api.nvim_buf_is_loaded(state.buf) then
		vim.fn.bufload(state.buf)
	end

	local filename = vim.fn.fnamemodify(filePath, ":t:r")

	local win_config = get_win_config(filename)
	state.win = vim.api.nvim_open_win(state.buf, true, win_config)

	create_bindings(state.buf, M.config.autosave)
end

M.open_period = function(format)
	local date = os.date(format)
	local filePath = create_file_if_not_exists(date)
	if filePath then
		vim.cmd("edit " .. vim.fn.fnameescape(filePath))
	end
end

M.toggle_period = function(format)
	local date = os.date(format)
	local filePath = create_file_if_not_exists(date)
	if filePath then
		M.toggle_file(filePath)
	end
end

return M
