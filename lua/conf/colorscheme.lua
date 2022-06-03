local M = {}

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
        'edge',
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
        function()
            vim.cmd [[packadd! edge]]
            vim.g.edge_diagnostic_virtual_text = 'colored'
            vim.g.edge_better_performance = 1
        end,
    },
}

local day_scheme_options = {
    name = {
        'dawnfox',
        'rose-pine',
        'tokyonight',
        'everforest',
        'gruvbox',
        'melange',
        'material',
        'edge',
        'solarized',
    },
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
        function()
            vim.cmd [[packadd! edge]]
            vim.g.edge_diagnostic_virtual_text = 'colored'
            vim.g.edge_better_performance = 1
        end,
        function()
            vim.cmd [[packadd! nvim-solarized-lua]]
            vim.g.solarized_italics = 0
        end,
    },
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

local day_to_night = 23
local night_to_day = 7

function M.pick_randomly()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    local time = os.date '*t'
    local bg = 1
    local rd = 0

    if (time.hour <= night_to_day) or (time.hour >= day_to_night) then
        bg = 1
        rd = math.random(1, #night_scheme_options.name)
    else
        bg = 2
        rd = math.random(1, #day_scheme_options.name)
    end

    pick_colorscheme(bg, rd)
end

function M.switch_colorscheme_with_day_night()
    -- vim.notify('load colorscheme at ' .. os.date '%c', vim.log.levels.INFO)
    M.pick_randomly()

    local time = os.date '*t'
    local hour_point_to_switch
    if time.hour >= day_to_night then
        hour_point_to_switch = 24 + night_to_day
    elseif time.hour < night_to_day then
        hour_point_to_switch = night_to_day
    else
        hour_point_to_switch = day_to_night
    end

    local mins_to_next_hour = 60 - time.min
    local hours_to_switch = hour_point_to_switch - (time.hour + 1)
    local total_ms_to_switch = (hours_to_switch * 60 + mins_to_next_hour) * 60 * 1000

    vim.defer_fn(M.switch_colorscheme_with_day_night, total_ms_to_switch)
end

M.switch_colorscheme_with_day_night()

local function select_colorscheme_based_on_bg(bg)
    local theme_options

    if bg == 1 then
        theme_options = night_scheme_options
    else
        theme_options = day_scheme_options
    end

    local items_to_be_selected = {}

    for i = 1, #theme_options.name do
        table.insert(items_to_be_selected, i)
    end

    vim.ui.select(items_to_be_selected, {
        prompt = 'select one colorscheme',
        format_item = function(item)
            return theme_options.name[item]
        end,
    }, function(theme_id)
        pick_colorscheme(bg, theme_id)
    end)
end

function M.pick_quickly()
    vim.ui.select({ 1, 2 }, {
        prompt = 'select the background of the colorscheme',
        format_item = function(item)
            if item == 1 then
                return 'dark'
            else
                return 'light'
            end
        end,
    }, function(bg)
        select_colorscheme_based_on_bg(bg)
    end)
end

vim.api.nvim_set_keymap(
    'n',
    '<Localleader>cs',
    ":lua require('conf.colorscheme').pick_quickly()<CR>",
    { noremap = true, silent = true }
)

return M
