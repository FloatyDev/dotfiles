-- =============================================================================
-- user/_dap.lua
-- =============================================================================

local env  = require("user.env")
local dap  = require("dap")
local repl = require("dap.repl")

-- ─── External terminal ───────────────────────────────────────────────────────
-- Resolved dynamically from PATH via env.lua — works on any machine.
if env.tools.terminal then
    dap.defaults.fallback.external_terminal = {
        command = env.tools.terminal,
        args    = { "-e" },
    }
    dap.defaults.fallback.focus_terminal = true
else
    vim.notify("[dap] No terminal emulator found — external terminal disabled", vim.log.levels.WARN)
end

-- ─── REPL commands ───────────────────────────────────────────────────────────
repl.commands = vim.tbl_extend("force", repl.commands, {
    exit = { "exit", ".exit", ".bye" },
    custom_commands = {
        [".echo"] = function(text)
            dap.repl.append(text)
        end,
        [".restart"] = dap.restart,
    },
})

-- ─── Keymaps ─────────────────────────────────────────────────────────────────
local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

map("n", "<Space>db", function() dap.toggle_breakpoint() end,                    "DAP: Toggle breakpoint")
map("n", "<Space>dB", function() dap.set_breakpoint() end,                       "DAP: Set breakpoint")
map("n", "<Space>lp", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end,                                                                              "DAP: Log point")
map("n", "<Space>dr", function() dap.repl.open() end,                            "DAP: Open REPL")
map("n", "<Space>dl", function() dap.run_last() end,                             "DAP: Run last")
map("n", "<F5>",      function() dap.continue() end,                             "DAP: Continue")
map("n", "<F10>",     function() dap.step_over() end,                            "DAP: Step over")
map("n", "<F11>",     function() dap.step_into() end,                            "DAP: Step into")
map("n", "<F12>",     function() dap.step_out() end,                             "DAP: Step out")

map({ "n", "v" }, "<Space>dh", function()
    require("dap.ui.widgets").hover()
end, "DAP: Hover")

map({ "n", "v" }, "<Space>dp", function()
    require("dap.ui.widgets").preview()
end, "DAP: Preview")

map("n", "<Space>df", function()
    local w = require("dap.ui.widgets")
    w.centered_float(w.frames)
end, "DAP: Frames")

map("n", "<Space>ds", function()
    local w = require("dap.ui.widgets")
    w.centered_float(w.scopes)
end, "DAP: Scopes")
