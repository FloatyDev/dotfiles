-- =============================================================================
-- user/init.lua
-- Load order matters:
--   1. env     — resolves all paths, must be first
--   2. plugins — lazy.nvim setup
--   3. options — vim options and keymaps
--   4. lsp     — language servers
--   5. indent  — indentation config
-- =============================================================================

require("user.env").check()   -- validate paths, warn about missing tools
require("user.plugins")
require("user.options")
require("user.lsp")
require("user._identation")
