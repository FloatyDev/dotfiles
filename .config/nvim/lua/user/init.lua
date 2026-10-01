-- =============================================================================
-- user/init.lua
-- Load only the startup-critical modules here. Feature modules are loaded by
-- lazy.nvim when their command, key, event, or filetype is used.
-- =============================================================================

vim.loader.enable()
vim.lsp.log.set_level("ERROR")

-- Mason's executables remain available even though its UI is loaded on demand.
local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
if not vim.env.PATH:find(mason_bin, 1, true) then
	vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

require("user.plugins")
require("user.options")

vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	once = true,
	callback = function()
		require("user.env").check()
	end,
})
