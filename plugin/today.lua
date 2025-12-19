vim.api.nvim_create_user_command("Today", function()
	require("today").create_today_file()
end, {})
