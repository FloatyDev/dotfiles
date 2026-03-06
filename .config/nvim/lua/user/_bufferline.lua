vim.opt.termguicolors = true
require("bufferline").setup({
  options = {
    -- Ensure bufferline doesn't touch winbar
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
        separator = false  -- Important
      }
    }
  }
})
