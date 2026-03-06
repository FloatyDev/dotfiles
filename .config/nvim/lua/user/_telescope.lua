local builtin = require('telescope.builtin')

vim.keymap.set('n', '<Space>s', builtin.find_files, {})
vim.keymap.set('n', '<Space>gr', builtin.live_grep, {})
vim.keymap.set('n', '<Space>R', builtin.oldfiles, {})
vim.keymap.set('n', '<Space>tr', builtin.treesitter, {})
vim.keymap.set('n', '<Space>lr', builtin.lsp_references, {})
vim.keymap.set('n', '<Space>gt', builtin.git_status, {})
vim.keymap.set('n', '<Space>ld', builtin.lsp_definitions, {})
vim.keymap.set('n', '<Space>li', builtin.lsp_implementations, {})
require('telescope').setup {
	defaults = {
		layout_config = {
			prompt_position = "bottom",
		},
		sorting_strategy = "ascending",
	},
}
