vim.cmd('syntax enable')
vim.cmd("let $NVIM_TUI_ENABLE_TRUE_COLOR=1")
vim.o.termguicolors = true
vim.o.guifont = "Fantasque_Sans_Mono_Regular_Nerd_Font_Complete:h17"

require'colorizer'.setup()

local colorschemePicker = {}

local colorSchemePick = function(style, theme)

    if style == 1 then

        if theme == 1 then
            vim.cmd("colorscheme nightfox")
        elseif theme == 2 then
            require('rose-pine').setup({
                dark_variant = "moon"
            })
            vim.cmd("colorscheme rose-pine")
            vim.o.background = "dark"
        elseif theme == 3 then
            vim.g.tokyonight_style = "night"
            vim.cmd("colorscheme tokyonight")
            vim.o.background = "dark"
        else
            vim.g.everforest_background = 'soft'
            vim.o.background = "dark"
            vim.cmd("colorscheme everforest")
        end

    else
        if theme == 1 then
            vim.cmd("colorscheme dawnfox")
        elseif theme == 2 then
            vim.o.background = "light"
            vim.cmd("colorscheme rose-pine")
        elseif theme == 3 then
            vim.g.tokyonight_style = "day"
            vim.cmd("colorscheme tokyonight")
        else
            vim.g.everforest_background = 'soft'
            vim.o.background = "light"
            vim.cmd("colorscheme everforest")
        end
    end

end

math.randomseed(os.time()) -- random initialize
math.random(); math.random(); math.random() -- warming up
local rd = math.random(1, 4)

local time = os.date("*t")
local init_style = 1

if (time.hour <= 7) or (time.hour >= 23) then
    init_style = 1
else
    init_style = 2
end


colorSchemePick(init_style, rd)

colorschemePicker.quickColorScheme = function()

    local styl = 1
    local thm = 1

    vim.ui.input({prompt = "1: night, 2: day"},
        function(x)
            styl = tonumber(x)
        end
    )

    vim.ui.input({prompt = "1: fox, 2: rose-pine, 3: tokyo, 4: forest"},
        function(x)
            thm = tonumber(x)
        end
    )

    colorSchemePick(styl, thm)
end

vim.api.nvim_set_keymap("n", "<LocalLeader><Localleader>cs", ":lua require('conf_colorscheme').quickColorScheme()<CR>", {noremap = true})

return colorschemePicker

