local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local output = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		error("Unable to install lazy.nvim:\n" .. output)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
	},
	{ "Mofiqul/dracula.nvim" },

	-- The rewritten main branch explicitly does not support lazy loading.
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("user._treesitter")
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("user._autopairs")
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			{
				"L3MON4D3/LuaSnip",
				build = "make install_jsregexp",
			},
			"onsails/lspkind-nvim",
		},
		config = function()
			require("user._cmp")
		end,
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{
				"SmiteshP/nvim-navic",
				config = function()
					require("user._nvim-navic")
				end,
			},
		},
		config = function()
			require("user.lsp")
		end,
	},
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
		build = ":MasonUpdate",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		cmd = { "LspInstall", "LspUninstall" },
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
		config = function()
			require("user.lsp.mason")
		end,
	},
	{
		"mfussenegger/nvim-jdtls",
		event = { "BufReadPre *.java", "BufNewFile *.java" },
		dependencies = { "neovim/nvim-lspconfig" },
	},

	{
		"mfussenegger/nvim-dap",
		keys = {
			"<F5>", "<F10>", "<F11>", "<F12>",
			"<Space>db", "<Space>dB", "<Space>lp", "<Space>dr", "<Space>dl",
			{ "<Space>dh", mode = { "n", "v" } },
			{ "<Space>dp", mode = { "n", "v" } },
			"<Space>df", "<Space>ds",
		},
		config = function()
			require("user._dap")
		end,
	},
	{
		"mfussenegger/nvim-dap-python",
		keys = { "<Space>dpr" },
		dependencies = { "mfussenegger/nvim-dap" },
		config = function()
			require("user._dap_python")
		end,
	},

	{
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		config = function()
			require("user._conform")
		end,
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("user._bufferline")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("user._gitsigns")
		end,
	},
	{
		"stevearc/oil.nvim",
		cmd = "Oil",
		keys = {
			{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("user._oil")
		end,
	},
	{
		"michaelb/sniprun",
		build = "bash ./install.sh 1",
		cmd = { "SnipRun", "SnipInfo", "SnipReset", "SnipReplMemoryClean" },
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "TermExec" },
		keys = { "<C-t>" },
		config = function()
			require("user._toggleterm")
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			"<Space>s", "<Space>gr", "<Space>R", "<Space>tr",
			"<Space>lr", "<Space>gt", "<Space>lD", "<Space>li",
		},
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("user._telescope")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("user._indentation")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
		config = function()
			require("user._lualine")
		end,
	},
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		cmd = "Dashboard",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("user._dashboard")
		end,
	},

	{
		"ravitemer/mcphub.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		build = "bundled_build.lua",
		config = function()
			require("mcphub").setup({ use_bundled_binary = true })
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionChat", "CodeCompanionCmd" },
		keys = {
			{ "<C-a>", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion actions" },
			{
				"<Space>a",
				function()
					require("codecompanion").toggle_cli({ agent = "codex" })
				end,
				mode = { "n", "v" },
				desc = "Toggle Codex CLI",
			},
			{ "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selection to CodeCompanion" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/codecompanion-history.nvim",
			"ravitemer/mcphub.nvim",
		},
		config = function()
			require("user._cc")
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("user._copilot")
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
		opts = {
			-- Keep source text stable while typing and render after leaving insert mode.
			render_modes = { "n", "c", "t" },
			sign = { enabled = false },
			completions = { lsp = { enabled = true } },
			latex = { enabled = false },
		},
	},
}, {
	defaults = { lazy = true },
	rocks = { enabled = false },
	change_detection = { notify = false },
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})
