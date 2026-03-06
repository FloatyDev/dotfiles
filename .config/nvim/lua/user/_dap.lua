local repl = require 'dap.repl'
local dap = require('dap')

dap.defaults.fallback.external_terminal = {
	command = '/usr/bin/alacritty',
	args = { '-e' },
}

dap.defaults.fallback.focus_terminal = true

repl.commands = vim.tbl_extend('force', repl.commands, {
	-- Add a new alias for the existing .exit command
	exit = { 'exit', '.exit', '.bye' },
	-- Add your own commands; run `.echo hello world` to invoke
	-- this function with the text "hello world"
	custom_commands = {
		['.echo'] = function(text)
			dap.repl.append(text)
		end,
		-- Hook up a new command to an existing dap function
		['.restart'] = dap.restart,
	},
}
)

-- keymaps
--vim.keymap.set(n, '<Space>dk', function() require('dap').continue() end)
vim.keymap.set('n', '<Space>db', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Space>dB', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Space>lp',
	function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Space>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Space>dl', function() require('dap').run_last() end)
vim.keymap.set({ 'n', 'v' }, '<Space>dh', function()
	require('dap.ui.widgets').hover()
end)
vim.keymap.set({ 'n', 'v' }, '<Space>dp', function()
	require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Space>df', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Space>ds', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.scopes)
end)
