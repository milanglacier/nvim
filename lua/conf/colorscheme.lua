local ColorschemePicker = {}

local function colorscheme_cmd(bg, theme)
    vim.o.background = bg
    vim.cmd('colorscheme ' .. theme)
end

local night_scheme_options = {

    {
        name = 'nightfox',
        cmd = function()
            vim.cmd [[packadd! nightfox.nvim]]
        end,
    },
    {
        name = 'rose-pine',
        cmd = function()
            vim.cmd [[packadd! rose-pine]]
            require('rose-pine').setup { dark_variant = 'moon' }
        end,
    },

    {
        name = 'tokyonight',
        cmd = function()
            vim.cmd [[packadd! tokyonight.nvim]]
            vim.g.tokyonight_style = 'night'
        end,
    },
    {
        name = 'everforest',
        cmd = function()
            vim.cmd [[packadd! everforest]]
            vim.g.everforest_background = 'soft'
        end,
    },
    {
        name = 'gruvbox',
        cmd = function()
            vim.cmd [[packadd! gruvbox.lua]]
        end,
    },
    {
        name = 'minischeme',
        cmd = function()
            vim.cmd [[packadd! mini.nvim]]
        end,
    },
    {
        name = 'kanagawa',
        cmd = function()
            vim.cmd [[packadd! kanagawa.nvim]]
        end,
    },

    length = 7,
}

local day_scheme_options = {

    {
        name = 'dawnfox',
        cmd = function()
            vim.cmd [[packadd! nightfox.nvim]]
        end,
    },
    {
        name = 'rose-pine',
        cmd = function()
            vim.cmd [[packadd! rose-pine]]
        end,
    },
    {
        name = 'tokyonight',
        cmd = function()
            vim.cmd [[packadd! tokyonight.nvim]]
            vim.g.tokyonight_style = 'day'
        end,
    },
    {
        name = 'everforest',
        cmd = function()
            vim.cmd [[packadd! everforest]]
            vim.g.everforest_background = 'soft'
        end,
    },
    {
        name = 'gruvbox',
        cmd = function()
            vim.cmd [[packadd! gruvbox.lua]]
        end,
    },

    length = 5,
}

local pick_colorscheme = function(bg, theme)
    if bg == 1 then -- background = dark
        night_scheme_options[theme].cmd()
        colorscheme_cmd('dark', night_scheme_options[theme].name)
    else -- background = light
        day_scheme_options[theme].cmd()
        colorscheme_cmd('light', day_scheme_options[theme].name)
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

local function concat_all_theme_names(schemeOptions)
    local all_names = ''
    for i, theme in ipairs(schemeOptions) do
        all_names = all_names .. i .. ':' .. theme.name .. ' '
    end

    return all_names
end

ColorschemePicker.pick_quickly = function()
    local bg = 1
    local theme = 1

    vim.ui.input({ prompt = '1: night, 2: day' }, function(x)
        bg = tonumber(x)
    end)

    local prompt = bg == 1 and concat_all_theme_names(night_scheme_options)
        or concat_all_theme_names(day_scheme_options)

    vim.ui.input({ prompt = prompt }, function(x)
        theme = tonumber(x)
    end)

    pick_colorscheme(bg, theme)
end

vim.api.nvim_set_keymap(
    'n',
    '<Localleader>cs',
    ":lua require('conf.colorscheme').pick_quickly()<CR>",
    { noremap = true }
)

return ColorschemePicker
