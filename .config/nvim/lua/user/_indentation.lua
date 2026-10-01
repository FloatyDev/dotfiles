require("ibl").setup({
	exclude = {
		buftypes = { "terminal", "nofile" },
		filetypes = {
			"help",
			"dashboard",
			"lazy",
			"mason",
			"NvimTree",
			"Trouble",
		},
	},
	indent = {
		char = "│",
	},
	scope = {
		enabled = false,
	},
	whitespace = {
		remove_blankline_trail = false,
	},
})
