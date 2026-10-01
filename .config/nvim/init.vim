if !has('nvim-0.11')
  echoerr 'This config requires Neovim 0.11 or newer. Run ~/.local/bin/nvim or fix your PATH.'
  finish
endif

" No registered remote plugins use these hosts. Disabling them avoids provider
" discovery and removes misleading health warnings.
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0
let g:loaded_python3_provider = 0
let g:loaded_ruby_provider = 0

lua require("user")
