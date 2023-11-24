require("nvim-tree").setup { -- BEGIN_DEFAULT_OPTS
	view = {
		side = "right"
	},
	renderer = {
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "ᐅ",
					arrow_open = "▼",
				},
			},
		},
	},
} -- END_DEFAULT_OPTS


local api = require('nvim-tree.api')

vim.keymap.set('n', '<space>e', api.tree.toggle)
vim.keymap.set('n', '<space>E', api.tree.focus)
