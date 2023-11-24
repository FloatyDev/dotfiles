---@diagnostic disable: undefined-global
require('packer').startup({
	function()
		use { 'wbthomason/packer.nvim' }

		-- themes
		use { 'Mofiqul/dracula.nvim' };

		use { "ellisonleao/gruvbox.nvim" }
		-- editing
		use { 'windwp/nvim-autopairs',
			config = function()
				require('user.autopairs')
			end,
		};
		use { 'nvim-treesitter/nvim-treesitter',
			config = function()
				require('user.treesitter')
			end,
		};

		-- lsp
		use { 'neovim/nvim-lspconfig' };

		use { "williamboman/mason.nvim",
		};

		use { "williamboman/mason-lspconfig.nvim" };

		-- cmp
		use { "hrsh7th/nvim-cmp",
			config = function()
				require('user.cmp')
			end,
		};

		use { "hrsh7th/cmp-nvim-lsp",
			config = function()
				require('user.cmp')
			end,
		};

		use { "hrsh7th/cmp-buffer" };

		use { "hrsh7th/cmp-path" };

		-- git-neovim integration
		use {
			'lewis6991/gitsigns.nvim',
			config = function()
				require('user.gitsigns')
			end,
		};

		-- snippet engine
		use { "L3MON4D3/LuaSnip" };

		-- UI
		use { 'kyazdani42/nvim-tree.lua',
			config = function()
				require('user.tree')
			end,
			requires = { 'kyazdani42/nvim-web-devicons' }
		};

		use { 'michaelb/sniprun', run = 'sh ./install.sh' }

		use {
			'akinsho/bufferline.nvim',
			config = function()
				require('user.barbar')
			end,
			tag = "v3.*",
			requires = 'nvim-tree/nvim-web-devicons',
		}

		use { "akinsho/toggleterm.nvim",
			config = function()
				require('user.toggleterm')
			end,

		};

		use { 'nvim-telescope/telescope.nvim',
			requires = { { 'nvim-lua/plenary.nvim' } },
			config = function()
				require('user.telescope')
			end,
		};

		use { "lukas-reineke/indent-blankline.nvim" };

		use {
			'nvim-lualine/lualine.nvim',
			requires = { 'kyazdani42/nvim-web-devicons', opt = true },
			config = function()
				require('user.lualine')
			end,
		}

		use {
			'glepnir/dashboard-nvim',
			event = 'VimEnter',
			config = function()
				require('user.dashboard')
			end,
			requires = { 'nvim-tree/nvim-web-devicons' }
		}
	end
})
