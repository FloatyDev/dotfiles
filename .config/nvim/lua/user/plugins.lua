local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

	-- themes
	"Mofiqul/dracula.nvim",

	--	"ellisonleao/gruvbox.nvim",

	"sainnhe/gruvbox-material",

	--editing
	{
		"windwp/nvim-autopairs",
		config = function()
			require("user._autopairs")
		end,
	},

	-- lsp
	"neovim/nvim-lspconfig",

	"williamboman/mason.nvim",

	"williamboman/mason-lspconfig.nvim",

	'mfussenegger/nvim-jdtls',

	{
		'mfussenegger/nvim-dap',
		config = function()
			require("user._dap")
		end,
	},

	{
		'mfussenegger/nvim-dap-python',
		dependencies = {
			'mfussenegger/nvim-dap',
		},
		config = function()
			require("user._dap_python")
		end,
	},
	--format
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("user._conform")
		end,
	},

	-- cmp
	{
		"hrsh7th/nvim-cmp",
		config = function()
			require("user._cmp")
		end,
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
		},
	},

	{
		'akinsho/bufferline.nvim',
		branch = "main",
		dependencies = 'nvim-tree/nvim-web-devicons',
		config = function()
			require("user._bufferline")
		end,
		--config = require("_bufferline")
	},

	-- git-neovim integration
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("user._gitsigns")
		end,
	},

	{
		'stevearc/oil.nvim',
		config = function()
			require("user._oil")
		end,
		-- Optional dependencies
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	{
		"michaelb/sniprun",
		build = "sh ./install.sh",
	},

	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("user._toggleterm")
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("user._telescope")
		end,
	},

	"lukas-reineke/indent-blankline.nvim",

	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("user._lualine")
		end,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		}
	},

	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		config = function()
			require("user._dashboard")
		end,
		dependencies = { { 'nvim-tree/nvim-web-devicons', name = 'tree_nvim_web_devicons' } },
	},

	{
		"onsails/lspkind-nvim",
	},
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			require("user._nvim-navic")
		end
	},

	{
		"ravitemer/mcphub.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		build = "bundled_build.lua",
		event = "VeryLazy",
		config = function()
			require("mcphub").setup({
				use_bundled_binary = true,
			})
		end,
	},

	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/codecompanion-history.nvim",
			"ravitemer/mcphub.nvim", -- ensures mcphub loads first
		},
		config = function()
			require("user._cc")
		end,
	},

	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("user._copilot")
		end
	},
	{
		"MeanderingProgrammer/render-markdown.nvim", -- Make Markdown buffers look beautiful
		ft = { "markdown", "codecompanion" },
		opts = {
			render_modes = true, -- Render in ALL modes
			sign = {
				enabled = false, -- Turn off in the status column
			},
		},
	},
})
