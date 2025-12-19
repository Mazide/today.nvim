local M = {}

local plugin_root = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h:h")
local default_opts = {
	templatepath = plugin_root .. "/template.md",
	folderpath = nil,
}

M.config = {}

M.setup = function(opt)
	M.config = vim.tbl_deep_extend("force", default_opts, opt or {})
end

M.create_today_file = function()
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

	local template = read_template()
	local date = os.date("%Y-%m-%d")

	if M.config.folderpath == nil then
		print("Please set folderpath in config")
		return
	end

	local fullFolderPath = vim.fn.expand(M.config.folderpath)
	local filePath = fullFolderPath .. date .. ".md"
	if file_exists(filePath) == false then
		local file, err = io.open(filePath, "a")
		if not file then
			print("Error creating Today file: " .. err)
			return
		end

		file:write(template)
		file:close()
		print("Today: " .. filePath)
	end
end

return M
