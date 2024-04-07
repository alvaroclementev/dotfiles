-- Load the common configuration
pcall(vim.cmd.source, "~/.vimrc")

-- General Options
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes:1" -- Merge the signcolumn and number column
vim.opt.mouse = "a" -- Setup the mouse
vim.opt.scrolloff = 10 -- Space when scrolling UP and DOWN
vim.opt.mousemoveevent = true

-- FIXME(alvaro): This is not the location where we want them to be anymore
vim.g.python3_host_prog = "~/.virtualenv/neovim/bin/python"

-- Lazy.nvim setup
-- Install Lazy (if necessary)
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- FIXME(alvaro): Review the colorscheme setup now that we have Lazy with priority and whatnot
-- Setup the plugins
-- FIXME(alvaro): Review which of these are used directly and which can be declared as dependency
require("lazy").setup({
  -- The base depenencies
  "nvim-lua/plenary.nvim",

  -- Colorschemes
  -- NOTE(alvaro): This is un-maintained, we should look into a fork (e.g: Shatur/neovim-ayu or Luxed/ayu-vim)
  { "Luxed/ayu-vim", lazy = false, priority = 1000 },
  -- We use this as the light colorscheme
  { "ericbn/vim-solarized", lazy = false, priority = 1000 },

  -- All hail the almighty tpope
  "tpope/vim-surround",
  "tpope/vim-commentary",
  "tpope/vim-repeat",
  "tpope/vim-fugitive",
  "tpope/vim-scriptease",

  -- TODO(alvaro): Look into this
  -- 'romainl/vim-qf'

  -- Eye candy
  "junegunn/vim-easy-align",
  { "nvim-tree/nvim-web-devicons", lazy = false, priority = 2000, opts = { default = true } },
  "norcalli/nvim-colorizer.lua",
  "lewis6991/gitsigns.nvim",

  -- TODO(alvaro): Here's a faster and more configurable alternative: https://github.com/goolord/alpha-nvim
  {
    "mhinz/vim-startify",
    init = function()
      -- Setup VimScript variables that configure how it works
      vim.g.startify_change_to_dir = false
      vim.g.startify_fortune_use_unicode = true
      vim.g.startify_relative_path = true
    end,
  },

  {
    "rcarriga/nvim-notify",
    lazy = false,
    -- Start before the rest of the plugins
    priority = 100,
    config = function()
      local notify = require "notify"
      ---@diagnostic disable-next-line: missing-fields
      notify.setup {
        -- See render styles in documentation
        render = "compact",
        stages = "fade_in_slide_out",
        timeout = 5000,
        top_down = true,
      }
      -- Set notify as the default notification handler for vim
      vim.notify = notify
    end,
  },

  -- Language specific
  "simrat39/rust-tools.nvim",
  "guns/vim-sexp",
  "tpope/vim-sexp-mappings-for-regular-people",
  -- "jpalardy/vim-slime",
  {
    "Olical/conjure",
    init = function()
      vim.g["conjure#filetypes"] = { "clojure", "fennel", "janet", "hy", "racket", "scheme", "lisp" }
      vim.g["conjure#filetype#julia"] = false
      vim.g["conjure#filetype#lua"] = false
      vim.g["conjure#filetype#python"] = false
      vim.g["conjure#filetype#rust"] = false
      vim.g["conjure#filetype#sql"] = false
    end,
  },
  "clojure-vim/vim-jack-in",
  "tpope/vim-dispatch",
  "radenling/vim-dispatch-neovim",

  -- Lua Neovim development
  {
    "folke/neodev.nvim",
    opts = {
      override = function(root_dir, library)
        -- TODO(alvaro): We should make this more portable... but for now this
        -- works
        if string.find(root_dir, "dotfiles/nvim/.config/nvim") then
          library.enabled = true
          library.plugins = true
        end
      end,
    },
  },

  -- Snippets
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",

  -- AI Assistant
  "github/copilot.vim",

  -- Testing
  "vim-test/vim-test",

  -- Misc
  {
    "nvim-tree/nvim-tree.lua",
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    opts = {
      sort_by = "case_sensitive",
      view = {
        adaptive_size = true,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = false,
      },
    },
    keys = {
      { "<Leader>b", ":NvimTreeFindFileToggle<CR>", desc = "Open NvimTree on the current file" },
    },
  },
  "justinmk/vim-dirvish",
  "folke/which-key.nvim",
  "ThePrimeagen/harpoon",

  { import = "user.plugins" },
}, {
  defaults = {
    version = "*", -- Install the latest stable version (following Semver rules)
  },
})

-- Fix the colorscheme so that the SignColumn does not have a different
-- background
-- Make sure it is applied everytime we change the colorscheme
-- NOTE: This must happen before sourcing the colorscheme, or else it's not
-- applied on first execution
local transparent_augroup = vim.api.nvim_create_augroup("transparent_signs", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  group = transparent_augroup,
  command = "highlight SignColumn guibg=NONE",
})

-- Set the colorscheme
require "alvaro.colorscheme"

-- FIXME(alvaro): Review if we are using these, since we are now using `term-edit`
-- Terminal Settings
local terminal_augroup = vim.api.nvim_create_augroup("alvaro_terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  group = terminal_augroup,
  command = "setlocal nonumber statusline=%{b:term_title} | startinsert",
})
vim.keymap.set("n", "<Leader>ts", ":20sp +term<CR>")
vim.keymap.set("n", "<Leader>tv", ":vsp +term<CR>")

-- Set the highlight on yank
local highlight_augroup = vim.api.nvim_create_augroup("highlight_yank", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  group = highlight_augroup,
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 300 }
  end,
})

-- Print the syntax group of the element under the cursor
local function syn_group()
  local pos = vim.fn.getpos "."
  local line = pos[2]
  local col = pos[3]
  local syn_id = vim.fn.synID(line, col, 1)
  print(vim.fn.synIDattr(syn_id, "name"), "->", vim.fn.synIDattr(vim.fn.synIDtrans(syn_id), "name"))
end
vim.api.nvim_create_user_command(
  "SynGroup",
  syn_group,
  { desc = "Print the syntax group of the element under the cursor" }
)
vim.keymap.set("n", "<LocalLeader>sg", ":<C-U>SynGroup<CR>", { silent = true })

-- Load the basic configuration
require "before"
require "alvaro"

-- FIXME(alvaro): Move this to its own file
-- Vim Test
vim.g["test#strategy"] = "neovim" -- TODO(alvaro): Review this
vim.keymap.set("n", "<Leader>tt", ":TestNearest<CR>", { silent = true })
vim.keymap.set("n", "<Leader>tf", ":TestFile<CR>", { silent = true })
vim.keymap.set("n", "<Leader>ta", ":TestSuite<CR>", { silent = true })
vim.keymap.set("n", "<Leader>tl", ":TestLast<CR>", { silent = true })
vim.keymap.set("n", "<Leader>tg", ":TestVisit<CR>", { silent = true })

-- FIXME(alvaro): Move this to utilities or formatting file
---@diagnostic disable-next-line: unused-local, unused-function
local function trim_whitespace()
  -- Store the current position of the cursor
  local pos = vim.fn.getpos "."
  -- Trim the trailing whitespace from the whole document
  -- NOTE: This may move the cursor
  vim.cmd [[ silent g/\s\+$/s/\s*$// ]]
  -- Restore the position before the trimming
  vim.fn.setpos(".", pos)
end

-- TODO(alvaro): Maybe enable this back?
-- Setup automatic space trimming on some files
-- autocmd FileType c,cpp,java,javascript,typescript,python,lua,vim autocmd BufWritePre <buffer> call TrimWhitespace()

-- Complex custom mappings
vim.keymap.set("n", "<LocalLeader>gg", ":<C-U>GithubOpen<CR>", { silent = true })
vim.keymap.set("n", "<LocalLeader>gG", ":<C-U>GithubOpenCurrent<CR>", { silent = true })
vim.keymap.set("n", "<LocalLeader>gg", ":GithubOpen<CR>", { silent = true })
vim.keymap.set("n", "<LocalLeader>gG", ":GithubOpenCurrent<CR>", { silent = true })

vim.api.nvim_create_user_command("JSONFormat", ":%! jq .", { desc = "Prettify JSON using jq" })
vim.api.nvim_create_user_command("JSONCompact", ":%! jq -c .", { desc = "Compact JSON using jq" })
