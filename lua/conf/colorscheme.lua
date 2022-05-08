local ColorschemePicker = {}

local function colorscheme_cmd(bg, theme)
    vim.o.background = bg
    vim.cmd('colorscheme ' .. theme)
end

local night_scheme_options = {
    name = {
        'nightfox',
        'rose-pine',
        'tokyonight',
        'everforest',
        'gruvbox',
        'minischeme',
        'kanagawa',
        'melange',
        'catppuccin',
        'material',
    },
    cmd = {
        function()
            vim.cmd [[packadd! nightfox.nvim]]
        end,
        function()
            vim.cmd [[packadd! rose-pine]]
            require('rose-pine').setup {
                dark_variant = 'moon',
                disable_italics = true,
            }
        end,
        function()
            vim.cmd [[packadd! tokyonight.nvim]]
            vim.g.tokyonight_style = 'night'
            vim.g.tokyonight_italic_keywords = false
            vim.g.tokyonight_italic_comments = false
        end,
        function()
            vim.cmd [[packadd! everforest]]
            vim.g.everforest_background = 'soft'
            vim.g.everforest_diagnostic_virtual_text = 'colored'
            vim.g.everforest_better_performance = 1
        end,
        function()
            vim.cmd [[packadd! gruvbox.lua]]
        end,
        function()
            vim.cmd [[packadd! mini.nvim]]
        end,
        function()
            vim.cmd [[packadd! kanagawa.nvim]]
            require('kanagawa').setup {
                globalStatus = vim.o.laststatus == 3,
                commentStyle = 'NONE',
                keywordStyle = 'NONE',
                variablebuiltinStyle = 'NONE',
            }
        end,
        function()
            vim.cmd [[packadd! melange]]
        end,
        function()
            vim.cmd [[packadd! catppuccin]]
            require('catppuccin').setup {
                term_colors = true,
                styles = {
                    comments = 'NONE',
                    functions = 'NONE',
                    keywords = 'NONE',
                    strings = 'NONE',
                    variables = 'NONE',
                },
                integrations = {
                    lsp_trouble = true,
                    neogit = true,
                    ts_rainbow = true,
                },
            }
        end,
        function()
            vim.cmd [[packadd! material.nvim]]
            vim.g.material_style = 'palenight'
            require('material').setup {
                contrast = {
                    floating_windows = true,
                    line_number = true,
                    sign_column = true,
                    sidebars = true,
                },
            }
        end,
    },
    length = 10,
}

local day_scheme_options = {
    name = { 'dawnfox', 'rose-pine', 'tokyonight', 'everforest', 'gruvbox', 'melange', 'material' },
    cmd = {
        function()
            vim.cmd [[packadd! nightfox.nvim]]
        end,
        function()
            vim.cmd [[packadd! rose-pine]]
            require('rose-pine').setup {
                disable_italics = true,
            }
        end,
        function()
            vim.cmd [[packadd! tokyonight.nvim]]
            vim.g.tokyonight_style = 'day'
            vim.g.tokyonight_italic_keywords = false
            vim.g.tokyonight_italic_comments = false
        end,
        function()
            vim.cmd [[packadd! everforest]]
            vim.g.everforest_background = 'soft'
            vim.g.everforest_diagnostic_virtual_text = 'colored'
            vim.g.everforest_better_performance = 1
        end,
        function()
            vim.cmd [[packadd! gruvbox.lua]]
        end,
        function()
            vim.cmd [[packadd! melange]]
        end,
        function()
            vim.cmd [[packadd! material.nvim]]
            vim.g.material_style = 'lighter'
            require('material').setup {
                contrast = {
                    floating_windows = true,
                    line_number = true,
                    sign_column = true,
                    sidebars = true,
                },
            }
        end,
    },
    length = 7,
}

local pick_colorscheme = function(bg, theme_id)
    if bg == 1 then -- background = dark
        night_scheme_options.cmd[theme_id]()
        colorscheme_cmd('dark', night_scheme_options.name[theme_id])
    else -- background = light
        day_scheme_options.cmd[theme_id]()
        colorscheme_cmd('light', day_scheme_options.name[theme_id])
    end
end

function ColorschemePicker.pick_randomly()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    local time = os.date '*t'
    local bg = 1
    local rd = 0

    if (time.hour <= 7) or (time.hour >= 23) then
        bg = 1
        rd = math.random(1, night_scheme_options.length)
    else
        bg = 2
        rd = math.random(1, day_scheme_options.length)
    end

    pick_colorscheme(bg, rd)
end

ColorschemePicker.pick_randomly()

-- auxiliary function to auto generate the list of popup menu
-- which uses nui.menu.item
-- for selecting themes (after the background is decided)
local function get_themes_table(bg_scheme_options, nui_item)
    local themes_table = {}
    for idx, theme in ipairs(bg_scheme_options.name) do
        table.insert(themes_table, nui_item { id = idx, text = theme })
    end
    return themes_table
end

---@param bg number
-- Given the background (day or night),
-- show the popup menu of the available theme
-- and make the selection
local function set_theme_menu(bg)
    local Menu = require 'nui.menu'
    local Event = require('nui.utils.autocmd').event

    local theme_lines

    if bg == 1 then
        theme_lines = get_themes_table(night_scheme_options, Menu.item)
    else
        theme_lines = get_themes_table(day_scheme_options, Menu.item)
    end

    local popup_opts = {
        relative = 'editor',
        position = '50%',
        size = {
            width = 20,
            height = #theme_lines,
        },
        win_options = {
            winblend = 10,
            winhighlight = 'NormalFloat:NormalFloat',
        },
        border = {
            style = 'rounded',
            text = {
                top = [[Choose theme]],
                top_align = 'center',
            },
        },
    }

    local menu = Menu(popup_opts, {
        lines = theme_lines,
        keymap = {
            focus_next = { 'j', '<Down>', '<Tab>' },
            focus_prev = { 'k', '<Up>', '<S-Tab>' },
            close = { '<Esc>', '<C-c>' },
            submit = { '<CR>', '<Space>' },
        },
        max_width = 20,
        on_close = function() end,
        on_submit = function(theme)
            pick_colorscheme(bg, theme.id)
        end,
    })

    -- mount the component
    menu:mount()
    -- close menu when cursor leaves buffer
    menu:on(Event.BufLeave, menu.menu_props.on_close, { once = true })
end

-- set the pop menu to choose the background is day or night,
-- after selecting that, show another popup menu that chooses the theme
local function set_bg_menu()
    local Menu = require 'nui.menu'
    local Event = require('nui.utils.autocmd').event

    local popup_opts = {
        relative = 'editor',
        position = '50%',
        size = {
            width = 20,
            height = 2,
        },
        win_options = {
            winblend = 10,
            winhighlight = 'NormalFloat:NormalFloat',
        },
        border = {
            style = 'rounded',
            text = {
                top = [[Choose background]],
                top_align = 'center',
            },
        },
    }

    local menu = Menu(popup_opts, {
        lines = {
            Menu.item { id = 1, text = 'night' },
            Menu.item { id = 2, text = 'day' },
        },
        keymap = {
            focus_next = { 'j', '<Down>', '<Tab>' },
            focus_prev = { 'k', '<Up>', '<S-Tab>' },
            close = { '<Esc>', '<C-c>' },
            submit = { '<CR>', '<Space>' },
        },
        max_width = 20,
        on_close = function() end,
        on_submit = function(bg)
            set_theme_menu(bg.id)
        end,
    })

    menu:mount()
    menu:on(Event.BufLeave, menu.menu_props.on_close, { once = true })
end

ColorschemePicker.pick_quickly = function()
    vim.cmd [[packadd! nui.nvim]]
    set_bg_menu()
end

vim.api.nvim_set_keymap(
    'n',
    '<Localleader>cs',
    ":lua require('conf.colorscheme').pick_quickly()<CR>",
    { noremap = true, silent = true }
)

return ColorschemePicker
