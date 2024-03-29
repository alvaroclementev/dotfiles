" Alvaro's Neovim configuration

" Load shared vim configuration
" FIXME(alvaro): Review the shared configuration with base vim
" Maybe move the common configuration to a `vimrc-no-plugins` file
source ~/.vimrc

" Enable vim.loader if it exists for faster startup
lua if vim.loader then vim.loader.enable() end

" Load the package manager (for now we have duplicated config for this
call plug#begin(stdpath('config') . '/plugged')
" Fuzzy finder

" All hail the almighty tpope
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-scriptease'

" TODO(alvaro): Try this out see how it works
Plug 'justinmk/vim-dirvish'

" Testing
Plug 'vim-test/vim-test'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
" Make LSP prettier
Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }

" Completion
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'PaterJason/cmp-conjure'
" TODO(alvaro): Checkout https://github.com/hrsh7th/cmp-nvim-lsp-document-symbol
Plug 'hrsh7th/nvim-cmp'
Plug 'onsails/lspkind-nvim'

" Formatting
Plug 'stevearc/conform.nvim', { 'tag': 'v4.*' }

" TODO(alvaro): Look into this
" Plug 'romainl/vim-qf'

" Eye candy
Plug 'junegunn/vim-easy-align'
Plug 'mhinz/vim-startify'
Plug 'j-hui/fidget.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim', { 'tag': 'v4.*' }
Plug 'norcalli/nvim-colorizer.lua'
Plug 'lewis6991/gitsigns.nvim'
Plug 'folke/trouble.nvim'
Plug 'rcarriga/nvim-notify'

" Colorschemes
Plug 'chriskempson/base16-vim'
Plug 'arcticicestudio/nord-vim'
" NOTE(alvaro): This is un-maintained, we should look into a fork (e.g: Shatur/neovim-ayu or Luxed/ayu-vim)
Plug 'Luxed/ayu-vim'
" As a light scheme
Plug 'ericbn/vim-solarized'
Plug 'nvim-lualine/lualine.nvim'  " This also can use nvim-web-devicons

" TreeSitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

" DAP - Debugging
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
Plug 'theHamsta/nvim-dap-virtual-text'

" Other languages
Plug 'simrat39/rust-tools.nvim'

" Lisps
Plug 'guns/vim-sexp'
Plug 'tpope/vim-sexp-mappings-for-regular-people'
Plug 'jpalardy/vim-slime'

" Clojure
Plug 'Olical/conjure', { 'tag': 'v4.*' }
Plug 'tpope/vim-dispatch'
Plug 'clojure-vim/vim-jack-in'
Plug 'radenling/vim-dispatch-neovim'

" For Lua in neovim development
Plug 'tjdevries/nlua.nvim'

" Telescope
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'

" Snippets
Plug 'L3MON4D3/LuaSnip', {'tag': 'v1.*'}
Plug 'saadparwaiz1/cmp_luasnip'

" Copilot
Plug 'github/copilot.vim'

" Misc
" FIXME(alvaro): This is built into neovim now
Plug 'gpanders/editorconfig.nvim'
Plug 'akinsho/toggleterm.nvim', {'tag': 'v2.*'}
Plug 'nvim-tree/nvim-tree.lua'
Plug 'justinmk/vim-dirvish'
Plug 'folke/which-key.nvim'
Plug 'ThePrimeagen/harpoon'

call plug#end()

" Disable netrw for nvim-tree
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" Merge the signcolumn and number column
set signcolumn=yes:1

" Fix the colorscheme so that the SignColumn does not have a different
" background
" Make sure it is applied everytime we change the colorscheme
" NOTE: This must happen before sourcing the colorscheme, or else it's not
" applied on first execution
augroup transparent_signs
    autocmd!
    autocmd ColorScheme * highlight SignColumn guibg=NONE
augroup END

" Set up the colorscheme
lua require 'alvaro.colorscheme'

" Mouse support inside tmux
" TODO: Check this for neovim
" set ttymouse=xterm2
set mouse=a

set scrolloff=10

" Terminal {{{
" Add add settings to these autocommands
augroup alvaro_terminal
    autocmd!
    autocmd TermOpen * setlocal nonumber statusline=%{b:term_title} | startinsert
augroup END

" Mapping to open a quick terminal below
nnoremap <Leader>ts :20sp +term<CR>
nnoremap <Leader>tv :vsp +term<CR>

" NOTE(alvaro): This is duplicated from the <C-H/J/K/L> that we have in .vimrc
" To use `ALT+{h,j,k,l}` to navigate windows from any mode:
tnoremap <A-h> <C-\><C-N><C-W>h
tnoremap <A-j> <C-\><C-N><C-W>j
tnoremap <A-k> <C-\><C-N><C-W>k
tnoremap <A-l> <C-\><C-N><C-W>l
inoremap <A-h> <C-\><C-N><C-W>h
inoremap <A-j> <C-\><C-N><C-W>j
inoremap <A-k> <C-\><C-N><C-W>k
inoremap <A-l> <C-\><C-N><C-W>l
nnoremap <A-h> <C-W>h
nnoremap <A-j> <C-W>j
nnoremap <A-k> <C-W>k
nnoremap <A-l> <C-W>l
" }}}

" Nvim necessary config
let g:python3_host_prog = '~/.virtualenv/neovim/bin/python'

" Load the Lua basic configuration
lua require'before'
lua require'alvaro'

" Highligh on yank
augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=300}
augroup END

" LSP Settings
" Client configuration (they are configured best using Lua)
lua require'alvaro.lsp'

" Completion {{{
" Remove the autocomplete option in some buffers
" autocmd FileType TelescopePrompt lua require('cmp').setup.buffer { enabled = false }
"}}}

" Diagnostic {{{
lua require'alvaro.diagnostic'
" }}}

" Startify {{{
let g:startify_change_to_dir = 0
let g:startify_fortune_use_unicode = 1
let g:startify_relative_path = 1
" }}}

" Allow for project specific settings
" TODO(alvaro): Look into these settings for project specific overrides
" set exrc
" set secure


" Vim test
nnoremap <silent> <Leader>tt :TestNearest<CR>
nnoremap <silent> <Leader>tf :TestFile<CR>
nnoremap <silent> <Leader>ta :TestSuite<CR>
nnoremap <silent> <Leader>tl :TestLast<CR>
nnoremap <silent> <Leader>tg :TestVisit<CR>


let g:test#strategy = "neovim"
" TODO(alvaro): Test if we want this
" let g:test#neovim#start_normal = 1 " If using neovim strategy


function! TrimWhitespace()
    let l:saved_pos = getpos('.')
    " NOTE(alvaro): This uses g: to only run this command on the lines that
    " require it, since it could make undo operations VERY slow on larger
    " files
    silent g/\s\+$/s/\s*$//
    " Restore the position of the cursor
    call setpos('.', l:saved_pos)
endfunction

" Trim the whitespace on certain filetypes
" NOTE(alvaro): No rust here since we use rustfmt anyway. Same with go
" TODO(alvaro): Think about vimscript where maybe sometimes we want to keep
" the whitespace
autocmd FileType c,cpp,java,javascript,typescript,python,lua,vim autocmd BufWritePre <buffer> call TrimWhitespace()

" Custom mapping for the GithubOpen
nnoremap <silent> <LocalLeader>gg :<C-U>GithubOpen<CR>
nnoremap <silent> <LocalLeader>gG :<C-U>GithubOpenCurrent<CR>
" TODO(alvaro): Review this one, we may want to pass the '<,'> range to the
" command call
xnoremap <silent> <LocalLeader>gg :GithubOpen<CR>
xnoremap <silent> <LocalLeader>gG :GithubOpenCurrent<CR>

" Colorscheme / Highlight related stuff
function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    echo synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name')
endfun

command! SynGroup :call SynGroup()
nnoremap <silent> <LocalLeader>sg :<C-U>SynGroup<CR>

" Conjure configuration
"clojure", "fennel", "janet", "hy", "julia", "racket",
"scheme", "lua", "lisp", "python", "rust", "sql"
let g:conjure#filetypes = ["clojure", "fennel", "janet", "hy", "racket", "scheme", "lisp"]
let g:conjure#filetype#julia = v:false
let g:conjure#filetype#lua = v:false
let g:conjure#filetype#python = v:false
let g:conjure#filetype#rust = v:false
let g:conjure#filetype#sql = v:false

" Other mappings {{{

" TODO(alvaro): Make this work on a range
" JSON formatting using `jq`
command! JSONFormat :%! jq .
command! JSONCompact :%! jq -c .

" }}}


