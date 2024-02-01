require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = { accept = "<C-j>" }
	},
	filetypes = {
		markdown = "true",
		help = "true",
		python = "true",
		lua = "true"
	},
})
