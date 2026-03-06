local n = "n"
local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"

require("dap-python").setup(path)

vim.keymap.set(n, '<Space>dpr', function() require('dap-python').test_method() end)
