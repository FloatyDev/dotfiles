local client_config = require("copilot.client.config")

-- copilot.lua can retain a request ID after Neovim has already completed it.
-- Guard this client only, so stale IDs are not sent through cancel_request().
client_config.add_callback(function(client)
	local cancel_request = client.cancel_request

	function client:cancel_request(request_id)
		local request = self.requests[request_id]
		if not request or request.type ~= "pending" then
			return false
		end

		return cancel_request(self, request_id)
	end
end)

require("copilot").setup({
	server_opts_overrides = {
		cmd_env = {
			NODE_NO_WARNINGS = "1",
		},
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		keymap = { accept = "<C-j>" },
	},
	filetypes = {
		markdown = true,
		help = true,
		python = true,
		lua = true,
	},
})
