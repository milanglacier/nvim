require('colorizer').setup()

local colorschemePicker = {}

local function colorschemeCmd(bg, theme)
    vim.o.background = bg
    vim.cmd('colorscheme ' .. theme)
end

local nightSchemeOptions = {

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

    length = 7,
}

local daySchemeOptions = {

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

    length = 5,
}

local colorSchemePick = function(bg, theme)
    if bg == 1 then -- background = dark
        if nightSchemeOptions[theme]['cmd'] ~= nil then
            nightSchemeOptions[theme].cmd()
        end

        colorschemeCmd('dark', nightSchemeOptions[theme].name)
    else -- background = light
        if daySchemeOptions[theme]['cmd'] ~= nil then
            daySchemeOptions[theme].cmd()
        end

        colorschemeCmd('light', daySchemeOptions[theme].name)
    end
end

function colorschemePicker.randomPick()
    math.randomseed(os.time()) -- random initialize
    local _ = math.random()
    _ = math.random()
    _ = math.random() -- warming up

    local time = os.date '*t'
    local bg = 1
    local rd = 0

    if (time.hour <= 7) or (time.hour >= 23) then
        bg = 1
        rd = math.random(1, nightSchemeOptions.length)
    else
        bg = 2
        rd = math.random(1, daySchemeOptions.length)
    end

    colorSchemePick(bg, rd)
end

colorschemePicker.randomPick()

local function getAllThemeNames(schemeOptions)
    local allNames = ''
    for i, theme in ipairs(schemeOptions) do
        allNames = allNames .. i .. ':' .. theme.name .. ' '
    end

    return allNames
end

colorschemePicker.quickColorScheme = function()
    local bg = 1
    local theme = 1

    vim.ui.input({ prompt = '1: night, 2: day' }, function(x)
        bg = tonumber(x)
    end)

    local prompt = bg == 1 and getAllThemeNames(nightSchemeOptions) or getAllThemeNames(daySchemeOptions)

    vim.ui.input({ prompt = prompt }, function(x)
        theme = tonumber(x)
    end)

    colorSchemePick(bg, theme)
end

vim.api.nvim_set_keymap(
    'n',
    '<Localleader>cs',
    ":lua require('conf.colorscheme').quickColorScheme()<CR>",
    { noremap = true }
)

return colorschemePicker
