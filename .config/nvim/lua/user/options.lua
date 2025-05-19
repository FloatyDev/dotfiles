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

vim.o.background = "dark" -- or "light" for light mode
vim.cmd("colorscheme gruvbox-material")

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
vim.opt.winbar = ""
vim.opt.cmdheight = 0
vim.opt.relativenumber = true
vim.opt.termguicolors = true

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
		vim.api.nvim_create_autocmd({ "InsertEnter", "BufModifiedSet" }, {
			buffer = 0,
			once = true,
			callback = function()
				persistbuffer()
			end
		})
	end
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
