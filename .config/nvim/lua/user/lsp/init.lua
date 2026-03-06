require("user.lsp.mason")
require("user.lsp.handlers")

local language_servers_installed = {
	"clangd",
	"lua_ls",
	"pyright",
	"bashls",
	"jsonls",
}

-- Mappings.
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>ld', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.documentSymbol = {
    dynamicRegistration = true,
    hierarchicalDocumentSymbolSupport = true,
}

local on_attach = function(client, bufnr)
	client.server_capabilities.semanticTokensProvider = nil

	-- Enable completion triggered by <c-x><c-o>
	vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

	-- Initialize navic if document symbols are supported
	if client.server_capabilities.documentSymbolProvider then
		require("nvim-navic").attach(client, bufnr)
	end

	-- Mappings.
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<space>f', function()
		require("conform").format({
			lsp_fallback = true,
			async = false,
			timeout_ms = 500,
		})
	end, bufopts)
end


for _, server in ipairs(language_servers_installed) do
	vim.lsp.config(server, {
        on_attach = on_attach,
        capabilities = capabilities,
    })
    vim.lsp.enable(server)
end
