local M = {}
M.say_hello = function()
	local function file_exists(name)
		local f = io.open(name, "r")
		if f ~= nil then
			io.close(f)
			return true
		else
			return false
		end
	end

	-- TODO:
	-- get template path from options
	-- get folder path from options
	-- show current date file in popup
	local templatePath = "./template.md"
	local date = os.date("%Y-%m-%d")
	local filePath = "./" .. date .. ".md"
	if file_exists(filePath) then
		print("File exists!")
	else
		local file, err = io.open(filePath, "a")
		if not file then
			print("Error creating file: " .. err)
			return
		end
		file:write("This is a test file.")
		file:close()
	end
end
return M
