-- =============================================================================
-- user/_dap_python.lua
-- =============================================================================

local env = require("user.env")

-- debugpy path comes from env.lua → resolves to Mason's managed venv.
-- env.check() (called from init.lua) will warn if debugpy is not installed.
require("dap-python").setup(env.paths.debugpy_python)

vim.keymap.set("n", "<Space>dpr", function()
    require("dap-python").test_method()
end, { silent = true, desc = "DAP Python: Test method" })
