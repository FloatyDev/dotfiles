vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Space>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanionChat' in the command line
vim.cmd([[cab cc CodeCompanionChat]])

require("codecompanion").setup({
	display = {
		action_palette = {
			width = 95,
			height = 10,
			prompt = "Prompt ",
			provider = "default",
			opts = {
				show_default_actions = true,
				show_default_prompt_library = true,
			},
		},
	},
	extensions = {
		mcphub = {
			callback = "mcphub.extensions.codecompanion",
			opts = {
				make_vars = false,
				make_slash_commands = true,
				show_result_in_chat = true,
			},
		},
		history = {
			enabled = true,
			opts = {
				-- Keymap to open history from chat buffer (default: gh)
				keymap = "gh",
				-- Keymap to save the current chat manually (when auto_save is disabled)
				save_chat_keymap = "sc",
				-- Save all chats by default (disable to save only manually using 'sc')
				auto_save = true,
				-- Number of days after which chats are automatically deleted (0 to disable)
				expiration_days = 0,
				-- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
				picker = "telescope",
				-- Automatically generate titles for new chats
				auto_generate_title = true,
				---On exiting and entering neovim, loads the last chat on opening chat
				continue_last_chat = false,
				---When chat is cleared with `gx` delete the chat from history
				delete_on_clearing_chat = false,
				---Directory path to save the chats
				dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
				---Enable detailed logging for history extension
				enable_logging = false,
			}
		}
	},
	adapters = {
		deepseek = function()
			return require("codecompanion.adapters").extend("deepseek", {
				env = {
					api_key = os.getenv("DEEPSEEK_API_KEY"),
				},
				schema = {
					model = {
						default = "deepseek-chat",
						values = { "deepseek-chat", "deepseek-reasoner" }
					}
				},

			})
		end,
	},
	strategies = {
		chat = {
			adapter = "deepseek",
		},
		inline = {
			adapter = "deepseek",
		},
		agent = {
			adapter = "deepseek",
		},
	},
})
