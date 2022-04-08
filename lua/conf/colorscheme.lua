local ColorschemePicker = {}

local function colorscheme_cmd(bg, theme)
    vim.o.background = bg
    vim.cmd('colorscheme ' .. theme)
end

local night_scheme_options = {

    { name = 'nightfox' },
    {
        name = 'rose-pine',
        cmd = function()
            require('rose-pine').setup { dark_variant = 'moon' }
        end,
    },

    {
        name = 'tokyonight',
        cmd = function()
            vim.g.tokyonight_style = 'night'
        end,
    },
    {
        name = 'everforest',
        cmd = function()
            vim.g.everforest_background = 'soft'
        end,
    },
    { name = 'gruvbox' },
    { name = 'minischeme' },
    { name = 'kanagawa' },
    { name = 'melange' },
    { name = 'catppuccin' },

    length = 9,
}

local day_scheme_options = {

    { name = 'dawnfox' },
    { name = 'rose-pine' },
    {
        name = 'tokyonight',
        cmd = function()
            vim.g.tokyonight_style = 'day'
        end,
    },
    {
        name = 'everforest',
        cmd = function()
            vim.g.everforest_background = 'soft'
        end,
    },
    { name = 'gruvbox' },
    { name = 'melange' },

    length = 6,
}

local pick_colorscheme = function(bg, theme)
    if bg == 1 then -- background = dark
        if night_scheme_options[theme]['cmd'] ~= nil then
            night_scheme_options[theme].cmd()
        end

        colorscheme_cmd('dark', night_scheme_options[theme].name)
    else -- background = light
        if day_scheme_options[theme]['cmd'] ~= nil then
            day_scheme_options[theme].cmd()
        end

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

local function concat_all_theme_names(scheme_options)

    local all_names = ''
    for i, theme in ipairs(scheme_options) do
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
