require("conform").setup({
	formatters_by_ft = {
		-- Conform will run multiple formatters sequentially
		python = { "isort","black" },
		lua = {"stylua"},
		markdown = {"prettier"},
	},
})
-- Format on save
--vim.api.nvim_create_autocmd("BufWritePre", {
--	pattern = "*",
--	callback = function(args)
--		require("conform").format({ bufnr = args.buf })
--	end,
--})
