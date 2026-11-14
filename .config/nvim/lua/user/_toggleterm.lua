require("toggleterm").setup {
	open_mapping = "<C-t>",
	direction = "horizontal",
	size = 23,
}

-- Claude Code in a vertical split on the right, toggled with <Space>a
local Terminal = require("toggleterm.terminal").Terminal
local claude = Terminal:new({
	cmd = "claude",
	direction = "vertical",
	hidden = true,
	close_on_exit = true,
	on_open = function(term)
		vim.cmd("startinsert")
	end,
})
claude.size = function() return math.floor(vim.o.columns * 0.4) end

vim.keymap.set({ "n", "v" }, "<Space>a", function() claude:toggle(math.floor(vim.o.columns * 0.4)) end,
	{ desc = "Toggle Claude" })
-- Also toggle from inside the terminal without leaving it
vim.keymap.set("t", "<A-a>", function() claude:toggle() end, { desc = "Toggle Claude" })
