-- Colorscheme setup
-- We use a simple file based system to automatically detect the preference
-- of light vs dark mode for the editor colorscheme
-- TODO(alvaro): Automatically detect changes of the screen mode
-- Can we set up a watcher on the `SCREEN_MODE_FILE` to listen to file
-- changes?
-- Another option is to Refresh the colorscheme on some kind of WinEnter,
-- TabEnter, FocusGained events so that it's lazy
vim.o.termguicolors = true
-- TODO(alvaro): Detect if catppuccin fails to import and use some safer
-- fallback
local DEFAULT_MODE = 'dark'
local DARK_MODE_FLAVOUR = 'macchiato'
local LIGHT_MODE_FLAVOUR = 'latte'
local SCREEN_MODE_FILE = vim.fn.expand("~/.alvaro_screen_mode")

local status, catppuccin = pcall(require, 'catppuccin')
if (not status) then return end


local function load_mode()
    if vim.fn.filereadable(SCREEN_MODE_FILE) == 0 then
        -- No file specified, so just return the default
        return DEFAULT_MODE
    end

    -- Try to load the value from the file
    local lines = vim.fn.readfile(SCREEN_MODE_FILE)
    if #lines ~= 1 then
        print("Invalid screen mode format")
        return DEFAULT_MODE
    else
        local mode = lines[1]
        if mode == "light" then
            return "light"
        elseif mode == "dark" then
            return "dark"
        else
            print("Invalid screen mode value '" .. mode .. "'")
            return DEFAULT_MODE
        end
    end
end

local function apply_colorscheme(mode)
    if mode == 'dark' then
        -- Apply the ayu-mirage colorscheme
        vim.o.background = 'dark'
        vim.cmd(string.format([[ Catppuccin %s ]], DARK_MODE_FLAVOUR))
    elseif mode == 'light' then
        -- Apply the solarized light colorscheme
        vim.o.background = 'light'
        vim.cmd(string.format([[ Catppuccin %s ]], LIGHT_MODE_FLAVOUR))
    else
        print("Unexpected color mode value! '" .. mode .. "'")
    end
end

function RefreshColorscheme()
    local mode = load_mode()
    apply_colorscheme(mode)
end

function SwitchColorscheme(opts)
    local mode = opts["fargs"][1]
    apply_colorscheme(mode)
end

-- Register a command for refreshing the colorscheme
vim.api.nvim_create_user_command('RefreshColorscheme', RefreshColorscheme, { nargs = 0 })
vim.api.nvim_create_user_command('SwitchColorscheme', SwitchColorscheme, {
    nargs = 1,
    complete = function()
        return { 'dark', 'light' }
    end
})

local function setup_catppuccin()
    local mode = load_mode()
    local flavour = DARK_MODE_FLAVOUR
    if mode == 'light' then
        flavour = LIGHT_MODE_FLAVOUR
    end
    vim.g.catppuccin_flavour = flavour
    catppuccin.setup {
        term_colors = true,
        compile = {
            enabled = true,
            path = vim.fn.stdpath("cache") .. "/catppuccin",
        },
        dim_inactive = {
            enabled = true,
        },
        styles = {
            -- Do not italice the conditionals (default is { "italic" })
            conditionals = {},
        },
        integrations = {
            gitsigns = true,
            lsp_saga = false,
            cmp = true,
            treesitter = true,
            telescope = true,
            -- Special Integrations
            fidget = true,
            native_lsp = {
                enabled = true,
                -- TODO(alvaro): Remove the background?
                virtual_text = {}
            }
        },
    }
    vim.cmd [[ colorscheme catppuccin ]]
end

-- Initial setup
setup_catppuccin()
