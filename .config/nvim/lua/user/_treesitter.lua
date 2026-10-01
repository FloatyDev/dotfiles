local parser_dir = vim.fn.stdpath("data") .. "/site"
local parsers = {
	"c",
	"lua",
	"python",
	"cpp",
	"java",
	"bash",
	"json",
	"toml",
	"vim",
	"vimdoc",
	"markdown",
	"markdown_inline",
	"html",
	"yaml",
}

require("nvim-treesitter").setup({
	install_dir = parser_dir,
})

vim.treesitter.language.register("json", "jsonc")

local installed = {}
for _, parser in ipairs(require("nvim-treesitter").get_installed()) do
	installed[parser] = true
end

local missing = vim.tbl_filter(function(parser)
	return not installed[parser]
end, parsers)

if #missing > 0 then
	vim.schedule(function()
		require("nvim-treesitter").install(missing)
	end)
end

local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = vim.list_extend(vim.deepcopy(parsers), { "jsonc" }),
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
