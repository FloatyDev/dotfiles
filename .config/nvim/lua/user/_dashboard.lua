local version = vim.version()
local bloody_nvim = {
	[[  ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓ ]],
	[[  ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒ ]],
	[[ ▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░ ]],
	[[ ▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██  ]],
	[[ ▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒ ]],
	[[ ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░ ]],
	[[ ░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░ ]],
	[[    ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░    ]],
	[[          ░    ░  ░    ░ ░        ░   ░         ░    ]],
	[[                                 ░                   ]],
	[[                                                     ]],
	[[                                                     ]],
	[[                                                     ]],
	"N E O V I M - v " .. version.major .. "." .. version.minor,
	[[                                                     ]],
	[[                                                     ]],
	[[                                                     ]],
}
local itadori = {
	[[ ⠀⠀⠀⠀⠀⠀⡀⠀⠀⢀⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ]],
	[[ ⢠⣧⢡⠊⡧⠾⢊⡷⣃⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ]],
	[[ ⡧⠋⠀⠀⠀⠀⡈⠸⢔⣣⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ]],
	[[ ⠀⠀⠀⠀⢀⡐⢮⡽⣶⣟⠒⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⣶⣦⣤⡀⠀⠀⠀⠀⠀⠀⠀ ]],
	[[ ⣄⣄⠀⢠⣿⣏⣑⣺⠞⢏⣆⠀⠀⠀⠀⠀⠀⠀⣯⣉⠙⢝⠟⠻⢻⣧⠀⠀⠀⠀⠀⠀⠀ ]],
	[[ ⠟⣇⢢⢰⣿⢿⠋⠉⠀⠠⣫⡆⠀⠀⠀⠀⠀⢀⣉⣽⠀⠀⠀⠀⠀⠀⢳⡀⠀⠀⠀⠀⠀ ]],
	[[ ⢆⣷⣾⡾⡈⠀⠀⠀⠴⠮⠜⢻⠀⠀⠀⠀⠐⠿⠒⠙⠲⠦⠤⢤⡒⠂⠁⠱⡀⠀⠀⠀⠀ ]],
	[[ ⠈⠋⠛⢿⡦⣦⡀⣀⣀⣤⣴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⢆⠀⠀⠳⡄⠀⠀⠀ ]],
	[[ ⠀⠀⠀⠀⣵⣭⣵⣮⣥⣴⣿⣦⣤⣄⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠘⡄⢣⡀⠀⠘⡄⠀⠀ ]],
	[[ ⠀⣀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣤⣤⣤⣀⣡⠀⠀⠘⢆⠸⡄⠀ ]],
	[[ ⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠙⢂⡀⢸⠀⠙⡄ ]],
	[[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠉⠁⠀⠀⠀⠀⣡ ]],
	[[ ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⠀⣀⣠⠾⠛ ]],
	[[ 									 ]],
	"N E O V I M - v " .. version.major .. "." .. version.minor,
	[[ 									 ]],
}

local center = {
	{
		desc = "Find File",
		keymap = "",
		key = "f",
		icon = "󰮗 ",
		action = "Telescope find_files",
	},

	{
		desc = "Recents",
		keymap = "",
		key = "r",
		icon = " ",
		action = "Telescope oldfiles",
	},

	{
		desc = "New File",
		keymap = "",
		key = "n",
		icon = " ",
		action = "enew",
	},

	{
		desc = "Lazy",
		keymap = "",
		key = "l",
		icon = "󰚰 ",
		action = "Lazy",
	},

	{
		desc = "Mason",
		keymap = "",
		key = "m",
		icon = " ",
		action = "Mason",
	},

	{
		desc = "Config",
		keymap = "",
		key = "c",
		icon = " ",
		action = "Telescope find_files cwd=~/.config/nvim",
	},

	{
		desc = "Exit",
		keymap = "",
		key = "q",
		icon = "󰗼 ",
		action = "exit",
	},
}

vim.api.nvim_create_autocmd("Filetype", {
	pattern = "dashboard",
	group = vim.api.nvim_create_augroup("Dashboard_au", { clear = true }),
	callback = function()
		vim.cmd([[
            setlocal buftype=nofile
            setlocal nonumber norelativenumber nocursorline noruler
        ]])
	end,
})

require("dashboard").setup({
	theme = "doom",
	config = {
		header = itadori,
		center = center,
		footer = function()
			return {
				"Type  :help<Enter>  or  <F1>  for on-line help",
			}
		end,
	},
	disable_move = true,
})
