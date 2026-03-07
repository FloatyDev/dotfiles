-- =============================================================================
-- user/env.lua
-- Single source of truth for all paths and environment-specific values.
-- Every other config file imports from here instead of hardcoding paths.
--
-- Usage:
--   local env = require("user.env")
--   env.paths.mason_bin        -- ~/.local/share/nvim/mason/bin
--   env.paths.debugpy_python   -- debugpy venv python
--   env.tools.terminal         -- resolved terminal binary from PATH
-- =============================================================================

local M = {}

-- ─── Neovim stdpath roots ────────────────────────────────────────────────────
-- These resolve correctly on every machine regardless of username or OS.
-- See :h stdpath for all available keys.
local data   = vim.fn.stdpath("data")    -- ~/.local/share/nvim
local config = vim.fn.stdpath("config")  -- ~/.config/nvim
local cache  = vim.fn.stdpath("cache")   -- ~/.cache/nvim

-- ─── Paths ───────────────────────────────────────────────────────────────────
M.paths = {
    -- Mason
    mason_root    = data .. "/mason",
    mason_bin     = data .. "/mason/bin",
    mason_pkg     = data .. "/mason/packages",

    -- Debugpy (installed by Mason)
    debugpy_python = data .. "/mason/packages/debugpy/venv/bin/python",

    -- JDTLS (installed by Mason)
    jdtls_bin     = data .. "/mason/bin/jdtls",

    -- lazy.nvim
    lazy_root     = data .. "/lazy",

    -- Config root
    config        = config,
}

-- ─── Tools ───────────────────────────────────────────────────────────────────
-- Resolved from PATH at runtime — never hardcoded absolute paths.
-- vim.fn.exepath returns "" if the binary is not found.

local function find_tool(candidates)
    for _, name in ipairs(candidates) do
        local p = vim.fn.exepath(name)
        if p ~= "" then return p end
    end
    return nil
end

M.tools = {
    -- Terminal emulator — tries common ones in order of preference
    terminal = find_tool({ "alacritty", "kitty", "wezterm", "gnome-terminal", "xterm" }),

    -- Python — prefers pyenv/conda managed versions
    python   = find_tool({ "python3", "python" }),

    -- Shell
    shell    = vim.fn.exepath(vim.o.shell) ~= "" and vim.o.shell or "/bin/bash",
}

-- ─── Guards ──────────────────────────────────────────────────────────────────
-- Warn at startup if critical tools are missing rather than cryptic errors later.

M.check = function()
    local warnings = {}

    if not M.tools.terminal then
        table.insert(warnings, "No terminal emulator found in PATH (tried: alacritty, kitty, wezterm)")
    end

    if vim.fn.filereadable(M.paths.debugpy_python) == 0 then
        table.insert(warnings,
            "debugpy not found at: " .. M.paths.debugpy_python ..
            "\n  Run :MasonInstall debugpy to fix this"
        )
    end

    if vim.fn.filereadable(M.paths.jdtls_bin) == 0 then
        table.insert(warnings,
            "jdtls not found at: " .. M.paths.jdtls_bin ..
            "\n  Run :MasonInstall jdtls to fix this"
        )
    end

    if #warnings > 0 then
        vim.defer_fn(function()
            for _, w in ipairs(warnings) do
                vim.notify("[env] " .. w, vim.log.levels.WARN)
            end
        end, 100)
    end
end

return M
