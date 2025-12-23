vim.api.nvim_create_user_command("Today", function()
	require("today").toogle_today()
end, {})
