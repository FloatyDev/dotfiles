--keymaps
local map = vim.keymap.set;

map('i', 'jk', '<Esc>');
map('i', 'jj', '<Esc>');

map('n', '<C-s>', ":w<CR>");
map('n', '<C-q>', ":bd!<CR>");
map('n', '<C-n>', ":bn<CR>");
map('n', '<C-p>', ":bp<CR>");
map('n', '<Space>`', ":Dashboard<CR>")
map('i', 'j<Tab>', function()
	require("luasnip").jump(1)
end);

-- themes
-- 	old gruvbox
--local terminal_backround = "#1D2021"; local linecursor_color = "#2e2927";
--require('gruvbox').setup({
--	overrides = {
--		GruvboxRedSign = { bg = terminal_backround },
--		GruvboxOrangeSign = { bg = terminal_backround },
--		GruvboxYellowSign = { bg = terminal_backround },
--		GruvboxBlueSign = { bg = terminal_backround },
--		GruvboxAquaSign = { bg = terminal_backround },
--		GruvboxGreenSign = { bg = terminal_backround },
--		--cursor
--		CursorLine = { bg = linecursor_color },
--		CursorLineNr = { bg = linecursor_color },
--		SignColumn = { bg = terminal_backround },
--		--Split
--		WinBarNC = { bg = terminal_backround },
--		--Dashboard
--		DashboardHeader = { fg = "#608B4E" },
--		--GitSigns
--		GitSignsChange = { fg = "#FE8019" },
--	},
--	contrast = "hard",
--})

vim.o.background = "dark" -- or "light" for light mode
vim.cmd("colorscheme gruvbox-material")

-- Custom navic highlights that match gruvbox-material
vim.api.nvim_set_hl(0, 'NavicIconsFile', { link = 'GruvboxOrange' })
vim.api.nvim_set_hl(0, 'NavicIconsModule', { link = 'GruvboxBlue' })
vim.api.nvim_set_hl(0, 'NavicIconsNamespace', { link = 'GruvboxAqua' })
vim.api.nvim_set_hl(0, 'NavicIconsClass', { link = 'GruvboxYellow' })
vim.api.nvim_set_hl(0, 'NavicIconsMethod', { link = 'GruvboxGreen' })
vim.api.nvim_set_hl(0, 'NavicText', { link = 'GruvboxFg1' })
vim.api.nvim_set_hl(0, 'NavicSeparator', { link = 'GruvboxGray' })

-- options
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.showmode = false
vim.opt.cursorline = true
vim.opt.splitright = true
vim.opt.hls = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.list = true
vim.opt.listchars = { trail = '·', tab = "  " }
vim.opt.laststatus = 3
vim.opt.signcolumn = 'yes'
vim.opt.number = true
vim.opt.cmdheight = 0
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.title = true
vim.opt.titlestring = "%<%F%=%l/%L - nvim"

vim.cmd [[
	augroup highlight_yank
	    autocmd!
	    au TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=200 }
	augroup END
]]

--delete unused buffers
local id = vim.api.nvim_create_augroup("startup", {
	clear = false
})

local persistbuffer = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	vim.fn.setbufvar(bufnr, 'bufpersist', 1)
end

vim.api.nvim_create_autocmd({ "BufRead" }, {
	group = id,
	pattern = { "*" },
	callback = function()
		local once = true
		local callback = function()
			persistbuffer()
		end
		if once then
			callback()
		end
	end,
})
vim.keymap.set('n', '<Space>b',
	function()
		local curbufnr = vim.api.nvim_get_current_buf()
		local buflist = vim.api.nvim_list_bufs()
		for _, bufnr in ipairs(buflist) do
			if vim.bo[bufnr].buflisted and bufnr ~= curbufnr and (vim.fn.getbufvar(bufnr, 'bufpersist') ~= 1) then
				vim.cmd('bd ' .. tostring(bufnr))
			end
		end
	end, { silent = true, desc = 'Close unused buffers' })
