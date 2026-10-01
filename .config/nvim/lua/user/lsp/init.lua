require("user.lsp.handlers")

local language_servers_installed = {
	"clangd",
	"lua_ls",
	"pyright",
	"bashls",
	"jsonls",
}

local opts = { silent = true }
vim.keymap.set("n", "<space>ld", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, opts)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, opts)

vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

local group = vim.api.nvim_create_augroup("user_lsp", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = group,
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		local bufnr = args.buf
		local bufopts = { silent = true, buffer = bufnr }

		if client:supports_method("textDocument/documentSymbol", bufnr) then
			require("nvim-navic").attach(client, bufnr)
		end

		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
		vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
		vim.keymap.set("n", "<space>th", function()
			local filter = { bufnr = bufnr }
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
		end, vim.tbl_extend("force", bufopts, { desc = "Toggle LSP inlay hints" }))
		vim.keymap.set("n", "<space>f", function()
			require("conform").format({
				bufnr = bufnr,
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			})
		end, vim.tbl_extend("force", bufopts, { desc = "Format buffer" }))
	end,
})

for _, server in ipairs(language_servers_installed) do
	vim.lsp.enable(server)
end
