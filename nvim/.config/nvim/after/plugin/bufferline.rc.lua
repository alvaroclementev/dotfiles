local status, bufferline = pcall(require, "bufferline")
if (not status) then return end

local highlights = {}
local status2, catppuccin = pcall(require, "catppuccin")
if status then
    highlights = require("catppuccin.groups.integrations.bufferline").get()
end

bufferline.setup {
    options = {
        mode = "buffers",
        numbers = "none",
        indicator = {
            icon = '▎',
            style = 'icon',
        },
        buffer_close_icon = '',
        modified_icon = '●',
        close_icon = '',
        left_trunc_marker = '',
        right_trunc_marker = '',
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_default_icon = true,
        show_close_icon = false,
        show_buffer_close_icons = false,
        always_show_bufferline = true,
        separator_style = "padded_slant",
    },
    highlights = highlights
}
