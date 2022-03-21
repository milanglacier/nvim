vim.cmd('syntax enable')
vim.cmd("let $NVIM_TUI_ENABLE_TRUE_COLOR=1")
vim.o.termguicolors = true
vim.o.guifont = "Monaco_Nerd_Font_Complete:h15"


require'colorizer'.setup()

local colorschemePicker = {}

local function colorschemeCmd(bg, theme)
    vim.o.background = bg
    vim.cmd("colorscheme ".. theme)
end


local nightSchemeOptions = {

    {name = "nightfox"},
    {name = "rose-pine",
     cmd = function() require('rose-pine').setup { dark_variant = "moon" } end
    },

    {name = "tokyonight", cmd = function() vim.g.tokyonight_style = "night" end},
    {name = "everforest", cmd = function() vim.g.everforest_background = 'soft' end},
    {name = 'gruvbox'},
    {name = 'minischeme'},

    length = 6
}

local daySchemeOptions = {

    {name = "dawnfox"},
    {name = "rose-pine"},
    {name = "tokyonight", cmd = function() vim.g.tokyonight_style = "day" end},
    {name = "everforest", cmd = function() vim.g.everforest_background = 'soft' end},
    {name = 'gruvbox'},

    length = 5
}

local colorSchemePick = function(style, theme)

    if style == 1 then

        if nightSchemeOptions[theme]['cmd'] ~= nil then
            nightSchemeOptions[theme].cmd()
        end

        colorschemeCmd('dark', nightSchemeOptions[theme].name)

    else

        if daySchemeOptions[theme]['cmd'] ~= nil then
            daySchemeOptions[theme].cmd()
        end

        colorschemeCmd('light', daySchemeOptions[theme].name)
    end

end

math.randomseed(os.time()) -- random initialize
math.random(); math.random(); math.random() -- warming up

local time = os.date("*t")
local init_style = 1
local rd = 0

if (time.hour <= 7) or (time.hour >= 23) then
    init_style = 1
    rd = math.random(1, nightSchemeOptions.length)
else
    init_style = 2
    rd = math.random(1, daySchemeOptions.length)
end

colorSchemePick(init_style, rd)

local function getAllThemeNames(schemeOptions)

    local allNames = ""
    for i, theme in ipairs(schemeOptions) do
        allNames = allNames .. i .. ":" .. theme.name .. " "
    end

    return allNames
end

colorschemePicker.quickColorScheme = function()

    local bg = 1
    local theme = 1

    vim.ui.input({prompt = "1: night, 2: day"},
        function(x)
            bg = tonumber(x)
        end
    )

    local prompt = bg == 1 and getAllThemeNames(nightSchemeOptions) or getAllThemeNames(daySchemeOptions)

    vim.ui.input({prompt = prompt},
        function(x) theme = tonumber(x) end
    )

    colorSchemePick(bg, theme)
end

vim.api.nvim_set_keymap("n", "<Localleader>cs", ":lua require('conf_colorscheme').quickColorScheme()<CR>", {noremap = true})

return colorschemePicker

