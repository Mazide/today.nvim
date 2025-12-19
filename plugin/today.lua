vim.api.nvim_create_user_command("TodayHello", function()
	require("today").say_hello()
end, {})
