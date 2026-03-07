local parser_dir = vim.fn.stdpath("data") .. "/site"

vim.opt.runtimepath:append(parser_dir)

require 'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all"
	ensure_installed = { "c", "lua", "python", "cpp", "java", "vim", "vimdoc" },
	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	highlight = {
		-- `false` will disable the whole extension
		enable = true,
	},
	parser_install_dir = parser_dir
}
