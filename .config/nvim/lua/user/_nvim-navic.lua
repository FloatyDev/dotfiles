-- Set up winbar to show navic

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter" }, {
	callback = function()
		vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
	end
})

require("nvim-navic").setup({
	icons = {
		File          = "󰈙 ", -- File icon that works universally
		Module        = "󰆧 ", -- Verified-working module icon
		Namespace     = "󰅩 ",
		Package       = "󰏖 ",
		Class         = "󰠱 ", -- Reliable class icon
		Method        = "󰆧 ", -- Method icon that renders consistently
		Property      = "󰜢 ",
		Field         = "󰜢 ",
		Constructor   = "󰆧 ",
		Enum          = "󰕘 ",
		Interface     = "󰕘 ",
		Function      = "󰊕 ",
		Variable      = "󰫧 ",
		Constant      = "󰏿 ",
		String        = "󰉾 ",
		Number        = "󰎠 ",
		Boolean       = "󰨙 ",
		Array         = "󰅪 ",
		Object        = "󰅩 ",
		Key           = "󰌋 ",
		Null          = "󰟢 ",
		EnumMember    = "󰕘 ",
		Struct        = "󰙅 ",
		Event         = "󰟫 ",
		Operator      = "󰆕 ",
		TypeParameter = "󰗴 ",
	},
	highlight = true,
	separator = " > ",
	depth_limit = 0,
	depth_limit_indicator = "..",
})
